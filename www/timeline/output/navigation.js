var current_content = null;
var current_ressource = null;

$(document).ready(function() {
  $("#timeline ul a").click(function() {
      show_content($(this).data('cid'), true);
      return false;
  });
  $("a.ressource").click(function() {
      show_ressource($(this).data('rid'), true);
      return false;
  });
  $("#show_timeline").click(function() {
      show_timeline();
      update_hash();
      return false;
  });

  load_hash();
  window.onhashchange = load_hash;

  if(window.history && window.history.pushState) {
    var url = build_hash();
    window.history.pushState(null, null, url);
    $(window).on('popstate', function(event) {
      load_hash();
    });

  }
});

function update()
{
    $("a.ressource").unbind("click");
    $("a.ressource").click(function() {
      show_ressource($(this).data('rid'));
      return false;
    });
    MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
}

function build_hash()
{
    var url = '#';
    if(current_content!=null)
    {
        if(current_ressource!=null)
        {
            url = '#/content/' + current_content + '/ressource/' + current_ressource;
        }
        else url = '#/content/' + current_content;
        return url;
    }
}

function update_hash()
{
    var url = build_hash();
    window.history.pushState({content_id: current_content, ressource_id: current_ressource}, "", url);
}

function load_hash()
{
    var matches = window.location.hash.match(/\/content\/(\d+)(\/ressource\/(\d+))?/);
    var change = current_content != matches[1] || current_ressource != matches[3];
    current_content = matches[1];
    current_ressource = matches[3];
    if(change)
    {
        if(current_content != null) show_content(current_content, false);
        else hide_content();
        if(current_ressource != null) show_ressource(current_ressource, false);
        else hide_ressource();
    }
}

function show_timeline()
{
  hide_content();
  hide_ressource();
  $("#show_timeline").hide();
  $("#timeline").show();
}

function hide_timeline()
{
  $("#timeline").hide();
  $("#show_timeline").show();
}

function show_content(id, updatehash)
{
  $.ajax({
    url: 'contents/content_' + id + '.html',
    type: 'GET',
    cache: false, // disable when ready
    success: function(data) {
      current_content = id;
      if(updatehash) update_hash();
      hide_timeline();
      data_object = $($.parseHTML(data)); 
      $('#content #timeline').html(data_object.find('#horizontal_timeline').html());
      $('#content .title').text(data_object.find('#title').text());
      $('#content .text').html(data_object.find('#text').html());
      $('#content .references').html(data_object.find('#references').html());
      $('#content .image').html(data_object.find('#image').html());
      $('#content').show();
      setTimeout(update, 100);
    },
    error: function(e) {
      console.log(e.message);
    }
  });
}

function hide_content(id)
{
  current_content = null;
  $("#content").hide();
}

function show_ressource(id, updatehash)
{
  hide_timeline();
  $.ajax({
    url: 'ressources/ressource_' + id + '.html',
    type: 'GET',
    cache: false, // disable when ready
    success: function(data) {
      current_ressource = id;
      if(updatehash) update_hash();
      data_object = $($.parseHTML(data)); 
      $('#ressource .title').text(data_object.find('#title').text());
      $('#ressource .text').html(data_object.find('#text').html());
      $('#ressource .references').html(data_object.find('#references').html());
      $('#ressource').show();
      setTimeout(update, 100);
    },
    error: function(e) {
      console.log(e.message);
    }
  });
}

function hide_ressource(id)
{
  current_ressource = null;
  $("#ressource").hide();
}
