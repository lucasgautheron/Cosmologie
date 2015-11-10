<?php
function enum()
{
    for($i = 0; $i < func_num_args(); $i++) define(func_get_arg($i), $i);
}

enum('EVENT_THEORETICAL', 'EVENT_EXPERIMENTAL');

class Timeline
{
    public $from;
    public $to;
}

class Event
{
    public $date;
    public $label;
    public $content_id;
    public $id;
}

class Content
{
    public $title;
    public $text;
    public $image;
    public $id;
}

class Ressource
{
    public $title;
    public $text;
    public $id;
}
?>
