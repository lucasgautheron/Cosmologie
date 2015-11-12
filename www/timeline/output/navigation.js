
$(document).ready(function() {
  $("#timeline ul a").click(function() {
      show_content($(this).data('cid'));
      return false;
  });
  $("a.ressource").click(function() {
      show_ressource($(this).data('rid'));
      return false;
  });
  $("#show_timeline").click(function() {
      show_timeline();
      return false;
  });
});

function show_timeline()
{
  hide_content();
  hide_ressource();
  $("#show_timeline").hide();
  $("#timeline").show(1000);
}

function hide_timeline()
{
  $("#timeline").hide(1000);
  $("#show_timeline").show();
}

function show_content(id)
{
  $.ajax({
    url: 'contents/content_' + id + '.html',
    type: 'GET',
    success: function(data) {
      hide_timeline();
      data_object = $($.parseHTML(data)); 
      $('#content #timeline').html(data_object.find('#horizontal_timeline').html());
      $('#content .title').text(data_object.find('#title').text());
      $('#content .text').html(data_object.find('#text').html()/*.replace(/\n/g, "<br />")*/);
      $('#content .image').html(data_object.find('#image').html());
      $('#content').show();
      MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
    },
    error: function(e) {
      console.log(e.message);
    }
  });
  
  show_ressource("103");
}

function hide_content(id)
{
  $("#content").hide();
}

function show_ressource(id)
{
  hide_timeline();

  $.ajax({
    url: 'ressources/ressource_' + id + '.html',
    type: 'GET',
    success: function(data) {
      data_object = $($.parseHTML(data)); 
      $('#ressource .title').text(data_object.find('#title').text());
      $('#ressource .text').html(data_object.find('#text').html()/*.replace(/\n/g, "<br />")*/);
      $('#ressource').show();
      MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
    },
    error: function(e) {
      console.log(e.message);
    }
  });
}

function hide_ressource(id)
{
  $("#ressource").hide();
}
