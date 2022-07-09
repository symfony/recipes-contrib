<?php

namespace App\Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as MongoDB;
use Oka\Notifier\ServerBundle\Model\Message as BaseMessage;

/**
 * @MongoDB\Document(collection="message")
 */
class Message extends BaseMessage
{
    /**
     * @MongoDB\Id()
     *
     * @var string
     */
    protected $id;
}
