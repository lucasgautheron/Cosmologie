#!/usr/bin/env python
"""
	Copyright (C) 2011 David Kozub <zub@linux.fjfi.cvut.cz>

	gnuplot-combine-svg.py is free software: you can redistribute it
	and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation, either version 3 of
	the License, or at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
import sys
import argparse
from lxml import etree
from copy import deepcopy
from xml.sax.saxutils import quoteattr
import StringIO

class SVGContainer:
	# Namespace fun. Don't ask me...
	_INKSCAPE_NS = '{http://www.inkscape.org/namespaces/inkscape}'
	_SVG_NS = '{http://www.w3.org/2000/svg}'
	_SVGNS = {
		'svg': 'http://www.w3.org/2000/svg',
		'inkscape': 'http://www.inkscape.org/namespaces/inkscape',
		'xlink': 'http://www.w3.org/1999/xlink'
	}
	_SVGNSMAP = {
		None: 'http://www.w3.org/2000/svg',
		'inkscape': 'http://www.inkscape.org/namespaces/inkscape',
		'xlink': 'http://www.w3.org/1999/xlink'
	}

	def __init__(self, extract_background = False):
		# Sigh... http://stackoverflow.com/questions/991864/creating-a-doctype-with-lxmls-etree
		svg_skeleton = """<?xml version="1.0" encoding="utf-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg
	xmlns="http://www.w3.org/2000/svg"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
/>"""
		self.tree = etree.parse(StringIO.StringIO(svg_skeleton))
		self.svg = self.tree.getroot()

		# as it's impossible to add DTD this way, replaced by ^
		#self.svg = etree.Element(SVGContainer._SVG_NS + "svg", nsmap=SVGContainer._SVGNSMAP)
		#self.tree = etree.ElementTree(self.svg)

		desc = etree.SubElement(self.svg, SVGContainer._SVG_NS + "desc")
		desc.text = "Produced by gnuplot-combine.svg.py."

		# container for defines that are used in write() to produce the <defs> subtree
		self.defs = {}
		self.box = None

		self.extract_bg = extract_background
		self.bg = {}

	def add_from_filename(self, fname, layer_name):
		print "combine: adding layer from %s" % fname
		with open(fname) as f:
			self.add_from_file(f, layer_name)

	def add_from_file(self, f, layer_name):
		tree = etree.parse(f)
		svg_list = tree.xpath("/svg:svg", namespaces=SVGContainer._SVGNS)
		assert len(svg_list) == 1
		self._add_tree(svg_list[0], layer_name)

	def _add_tree(self, root, layer_name):
		TITLE = "{http://www.w3.org/1999/xlink}title"

		assert(root.tag == '{http://www.w3.org/2000/svg}svg')

		# view box
		if root.attrib.has_key("viewBox"):
			box_list = root.attrib["viewBox"].split()
			x1 = int(box_list[0])
			y1 = int(box_list[1])
			x2 = int(box_list[2])
			y2 = int(box_list[3])

			if self.box == None:
				self.box = [x1, y1, x2, y2]
			else:
				self.box[0] = min([self.box[0], x1])
				self.box[1] = min([self.box[1], y1])
				self.box[2] = max([self.box[2], x2])
				self.box[3] = max([self.box[3], y2])

		# defines
		for defs in root.xpath("svg:defs", namespaces=SVGContainer._SVGNS):
			for d in defs:
				d_id = d.attrib["id"]
				if self.defs.has_key(d_id):
					# test if they don't clash
					assert self._subtrees_equal(self.defs[d_id], d)
				else:
					self.defs[d_id] = d

		# create group for layer
		layer = self._create_layer(layer_name)
		self.svg.append(layer);

		# gnuplot puts the contents of the graph inside an <a> tag
		# unfortunately it puts some shared parts like the legend inside
		# that <a> tag too => unwrap the contents so that it can be used
		# in bg extraction
		for a in root.xpath("svg:a", namespaces=SVGContainer._SVGNS):
			for c in a.getchildren():
				a.addnext(c)
			a.getparent().remove(a)

		# the line part of the legend is combined with the graph itself
		# inside one <path/> element... extracting that would be a major
		# pain...

		# gnuplot (as of version 4.4 at least) is keen on producing
		# empty groups... let's drop these, AFAIK they have no effect
		# this doesn't remove nested empty <s>s (<g><g/></g>), but who cares...
		if self.extract_bg:
			bg_group = etree.Element(SVGContainer._SVG_NS + "g")
			self.bg[layer] = bg_group
			for g in root.xpath("svg:g", namespaces=SVGContainer._SVGNS):
				if (len(g) > 0):
					bg_group.append(g)
				#else: ignore
		else:
			for g in root.xpath("svg:g", namespaces=SVGContainer._SVGNS):
				if (len(g) > 0):
					layer.append(g)
				#else: ignore

#		# no longer used as we do the <a> unwrapping above...
#		for a in root.xpath("svg:a", namespaces=SVGContainer._SVGNS):
#			layer.append(deepcopy(a))
#			a_copy = layer[0]
#			a_copy.attrib[TITLE] = layer_name

	# write() must not be called multiple times.
	# At first it was intended for this to be ok, but with bg extracting
	# this would add complexity (and memory consumptions).
	# If it's needed, _update_background() (and it's usage) needs to be
	# adapted.
	def write(self, fname):
		self._update_defs()
		self._update_viewBox()
		self._update_background()
		with open(fname, "w") as f:
			self.tree.write(f, xml_declaration=True, encoding='utf-8',
				pretty_print=True, standalone=False)

	def _insert_after_first(self, tag, element):
		f = self.svg.find(tag, namespaces=SVGContainer._SVGNS)
		if f != None:
			f.addnext(element)
		else:
			self.svg.append(element)

	def _insert_before_first(self, tag, element):
		f = self.svg.find(tag, namespaces=SVGContainer._SVGNS)
		if f != None:
			f.addprevious(element)
		else:
			self.svg.insert(0, element)

	def _update_defs(self):
		# remove any old defs
		for defs in self.svg.xpath("svg:defs", namespaces=SVGContainer._SVGNS):
			defs.getparent().remove(defs)

		defs = etree.Element(SVGContainer._SVG_NS + "defs")

		# insert after <desc>
		self._insert_after_first("svg:desc", defs)

		# recreate new subtree based on self.defs
		for def_id, def_element in self.defs.iteritems():
			defs.append(deepcopy(def_element))

	def _update_viewBox(self):
		self.svg.attrib["viewBox"] = "%f %f %f %f"%(self.box[0], self.box[1], self.box[2], self.box[3])

	def _update_background(self):
		if not self.extract_bg:
			return

		print "_update_background: extracting common background"

		layer_name = "common_bg"
		# intersect all backgrounds to create  common background
		common_bg = None
		for layer, bg_group in self.bg.iteritems():
			if common_bg == None:
				common_bg = bg_group
			else:
				common_bg = self._tree_intersect(common_bg, bg_group)

		if common_bg != None:
			common_layer = self._create_layer(layer_name)
			# insert before other <g>s
			self._insert_before_first("svg:g", common_layer)
			common_layer.append(common_bg)

		print "_update_background: adding bg differences to respective layers"

		# add differences into each layer
		for layer, bg_group in self.bg.iteritems():
			bg_diff = self._tree_difference(bg_group, common_bg)
			if bg_diff != None:
				# it's background, so it should come before the real contents
				layer.insert(0, bg_diff)

	# Creates a SVG group that inkscape interprets as layer with given label.
	def _create_layer(self, label):
		layer = etree.Element(SVGContainer._SVG_NS + "g")
		layer.attrib[SVGContainer._INKSCAPE_NS + "label"] = label
		layer.attrib[SVGContainer._INKSCAPE_NS + "groupmode"] = "layer"
		return layer;

	def _subtrees_equal(self, l, r):
		# compare tag name
		if l.tag != r.tag:
			return False

		# compare attributes
		if l.attrib != r.attrib:
			return False

		# compare children
		if len(l) != len(r):
			return False
		for i in range(0, len(l)):
			if not self._subtrees_equal(l[i], r[i]):
				return False

		return True

	# TODO: this needs beefing up, now it's just shallow compare
	def _similarity_measure(self, a, b):
		if not self._shallow_node_equals(a, b):
			return None

		# TODO: measure subtree similarity...
		return 1.0

	# We take the bold (and wrong) assumption we don't care about
	# leading and trailing whitespace...
	def _shallow_node_equals(self, a, b):
		return a.tag == b.tag and a.attrib == b.attrib and \
		( (a.text == None and b.text == None) or (a.text.strip() == b.text.strip()))

	# Slightly misleading name. This creates a deep copy of the
	# element, but does not copy any children. So it's 1-level deep
	# copy. :)
	def _shallow_copy(self, element):
		v = etree.Element(element.tag)
		for attr, val in element.attrib.iteritems():
			v.attrib[attr] = val
		v.text = element.text;
		return v

	# Generally order matters, but here we assume it does not.
	# This should work well enough.
	def _tree_intersect(self, t, u):
		if not self._shallow_node_equals(t, u):
			return None

		v = self._shallow_copy(t)

		# intersect children
		# we have to match them somehow :-/
		u_matched = [False for i in range(0, len(u))];
		for tc in t.getchildren():
			# try to find a match among not-yet-matched u children:
			similarity = [None for i in range(0, len(u))]
			for i in range(0, len(u)):
				if not u_matched[i]:
					similarity[i] = self._similarity_measure(tc, u[i])
				else:
					similarity[i] = None
			max_sim = max(similarity)
			if max_sim != None:
				argmax = similarity.index(max_sim)
				assert not u_matched[argmax]
				u_matched[argmax] = True
				uc = u[argmax]
				w = self._tree_intersect(tc, uc)
				assert w != None
				v.append(w)
			#else: nothing similar enough

		return v

	def _tree_difference(self, t, u):
		if self._subtrees_equal(t, u):
			return None

		if len(u) != 0:
			v = self._shallow_copy(t)

			u_matched = [False for i in range(0, len(u))];
			for tc in t.getchildren():
				# try to find a match among not-yet-matched u children:
				similarity = [None for i in range(0, len(u))]
				for i in range(0, len(u)):
					if not u_matched[i]:
						similarity[i] = self._similarity_measure(tc, u[i])
					else:
						similarity[i] = None
				max_sim = max(similarity)
				if max_sim != None:
					argmax = similarity.index(max_sim)
					assert not u_matched[argmax]
					u_matched[argmax] = True
					uc = u[argmax]
					if not self._subtrees_equal(tc, uc):
						# similar, but not same -> add + recurse
						w = self._tree_difference(tc, uc)
						assert w != None
						v.append(w)
					#else: subtrees are identical -> remove
				else:
					v.append(deepcopy(tc))
		else:
			v = deepcopy(t)

		return v

if __name__ == "__main__":
	# parse args
	parser = argparse.ArgumentParser(description='Combine multiple gnuplot SVG plots into a single, inkscape-friendly, SVG file.')
	parser.add_argument('input_files', metavar='FILENAME', type=file, nargs='+',
					help='SVG file to include in the output')
	parser.add_argument('--out', '-o', dest='out_fname', type=unicode, required=True,
					help='output file name')
	parser.add_argument('--extract-background', '-b', dest='extract_bg', action='store_true',
					default=False,
					help='try to extract common background (e.g. axes, legend, ...) into '
					'a separate layer; this includes quite some heuristics that could be '
					'improved, but it should work for simple situations')

	args = parser.parse_args()

	container = SVGContainer(args.extract_bg)
	for f in args.input_files:
		print "adding file", f.name
		container.add_from_file(f, f.name)

	container.write(args.out_fname)
