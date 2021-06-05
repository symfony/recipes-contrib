<?php

namespace App\Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as MongoDB;
use Oka\Notifier\ServerBundle\Model\SendReport as BaseSendReport;

/**
 * @MongoDB\Document(collection="send_report")
 */
class SendReport extends BaseSendReport
{
    /**
     * @MongoDB\Id()
     *
     * @var string
     */
    protected $id;

    public function __construct()
    {
        parent::__construct();

        // your own logic
    }
}
