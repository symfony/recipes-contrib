<?php
/*
 Plugin Name: Symfony Bridge
 Plugin URI: http://www.geniusconception.com/
 Description: For use symfony service in wordpress, and spread event trought symfony from wp.
 Version: 0.0.1
 Author: Olivier M. Mukadi
 Author URI: http://www.geniusconception.net/
*/
/**
 * retreive symfony service
 */
function symfony ($id){
    global $sf;
    return $sf($id);
}

function symfony_container_ready(){
    return isset($GLOBALS['sf']);
}
/**
 * dispatch event in symfony
 */
function symfony_dispatch($name, \Mukadi\WordpressBundle\Event\WordpressEvent $event)
{
    if (!symfony_container_ready()) return;
    return symfony('event_dispatcher')->dispatch($name, $event);
}
