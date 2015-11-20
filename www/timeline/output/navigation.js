var modules_history = new Array(1);

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

function update()
{
    $("a.ressource").unbind("click");
    $("a.ressource").click(function() {
      show_ressource($(this).data('rid'));
      return false;
    });
    MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
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

function show_content(id)
{
  modules_history.push(new Array("content", id));
  $.ajax({
    url: 'contents/content_' + id + '.html',
    type: 'GET',
    cache: false, // disable when ready
    success: function(data) {
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
  $("#content").hide();
}

function show_ressource(id)
{
  modules_history.push(new Array("ressource", id));
  hide_timeline();
  $.ajax({
    url: 'ressources/ressource_' + id + '.html',
    type: 'GET',
    cache: false, // disable when ready
    success: function(data) {
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
  $("#ressource").hide();
}
