#!/usr/bin/env python
"""
	Copyright (C) 2011 David Kozub <zub@linux.fjfi.cvut.cz>

	svg-animate-layers.py is free software: you can redistribute it
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
import StringIO

# see:
# http://www.w3.org/TR/SVG11/animate.html
# http://www.w3.org/TR/smil-animation/#AnimationElements

class EquidistantTimeline:
	# period is in ms
	def __init__(self, period):
		assert period > 0
		self.period = period
		self.t = 0

	def get_next(self):
		t = self.t
		self.t += self.period
		return t

class SVGLayerAnimator:
	# Namespace fun. Don't ask me...
	_INKSCAPE_NS = '{http://www.inkscape.org/namespaces/inkscape}'
	_SVG_NS = '{http://www.w3.org/2000/svg}'
	_SVGNS = {
		'svg': 'http://www.w3.org/2000/svg',
		'inkscape': 'http://www.inkscape.org/namespaces/inkscape',
		'xlink': 'http://www.w3.org/1999/xlink'
	}

	END_CLEAR = 0
	END_KEEP = 1
	END_REPEAT = 2

	def __init__(self, f, timeline, end_mode, static_layers = None):
		self.tree = etree.parse(f)
		root = self.tree.getroot()
		assert(root.tag == '{http://www.w3.org/2000/svg}svg')
		self.svg = root
		self.timeline = timeline
		if static_layers != None:
			self.static_layers = set(static_layers)
		else:
			self.static_layers = set([])
		self.end_mode = end_mode

	def write(self, fname):
		self._update()
		with open(fname, "w") as f:
			self.tree.write(f, xml_declaration=True, encoding='utf-8',
				pretty_print=True, standalone=False)

	def _update(self):
		t = self.timeline.get_next()
		idx = 0;
		for g in self.svg.xpath("svg:g", namespaces=SVGLayerAnimator._SVGNS):
			if not self._is_layer_static(g):
				g.attrib['visibility'] = 'hidden';
				t1 = self.timeline.get_next()
				s = etree.SubElement(g, SVGLayerAnimator._SVG_NS + "set") # Which NS?
				s.attrib['id'] = 'a_frame_' + str(idx);
				idx = idx+1
				s.attrib['attributeName'] = 'visibility'
				s.attrib['to'] = 'visible'
				s.attrib['begin'] = str(t) + 'ms'
				s.attrib['dur'] = str(t1 -t) + 'ms'
				t = t1
			#else: nothing to do

		if s == None:
			# this shouldn't normally happen - it would mean no animated
			# layer ws added
			return

		if self.end_mode == SVGLayerAnimator.END_KEEP:
			del(s.attrib['dur'])
		elif self.end_mode == SVGLayerAnimator.END_REPEAT:
			# fix up all begin tags
			# this could have been done in one pass, but then
			# it would place additional requirements on the timeline,
			# this way the timeline can be trivial

			# t is the "next frame" time, eventually we might want a diff.
			# time value (i.e. how long to wait before repeat), but it's
			# ok for now
			# Note: we also assume there were not <set> tags in input!
			for s in self.svg.xpath("svg:g/svg:set", namespaces=SVGLayerAnimator._SVGNS):
				s.attrib['begin'] = s.attrib['begin'] + ";" + s.attrib['id'] + ".begin+" + str(t) + "ms"
		elif self.end_mode == SVGLayerAnimator.END_CLEAR:
			pass
		else:
			# unknown end mode specified
			assert False

	def _is_layer_static(self, g):
		LABEL_ATTR = SVGLayerAnimator._INKSCAPE_NS + "label"
		if g.attrib.has_key(LABEL_ATTR):
			return g.attrib[LABEL_ATTR] in self.static_layers
		else:
			return False

if __name__ == "__main__":
	# parse args
	parser = argparse.ArgumentParser(description='Animate layers in a SVG file.')
	parser.add_argument('input_file', metavar='FILENAME', type=file, nargs=1, action='store',
					help='SVG file to animate in the output')
	parser.add_argument('--static', '-s', dest='static_layers', type=unicode, action='append',
					help='layers that are to be always visible')
	parser.add_argument('--out', '-o', dest='out_fname', type=unicode, required=True,
					help='output file name')
	parser.add_argument('--end', '-e', dest='end_mode', type=unicode, default='keep',
					help='select what happens when the end of the animation sequence is reached, use one of: '
						'clear, keep, repeat')
	parser.add_argument('--fps', '-f', dest='fps', type=int, default=1,
					help='number of animation frames to be displayed per second')

	args = parser.parse_args()

	end_mode = 0;
	if args.end_mode == 'clear':
		end_mode = SVGLayerAnimator.END_CLEAR
	elif args.end_mode == 'keep':
		end_mode = SVGLayerAnimator.END_KEEP
	elif args.end_mode == 'repeat':
		end_mode = SVGLayerAnimator.END_REPEAT
	else:
		print "Wrong argument value for parameter --end (-e). Please use one of:"
		print "clear, keep, repeat"
		sys.exit(1)

	timeline = EquidistantTimeline(1000 / args.fps)
	animator = SVGLayerAnimator(args.input_file[0], timeline, end_mode, args.static_layers)
	animator.write(args.out_fname)
