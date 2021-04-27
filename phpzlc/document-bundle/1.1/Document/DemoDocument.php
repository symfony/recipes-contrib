<?php

namespace App\Document;

use PHPZlc\Document\Document;

class DemoDocument extends Document
{
    public function demoAction()
    {
        $this->add()
            ->setTitle('演示接口')
            ->setUrl('/demo')
            ->setReturnType('html')
            ->setReturn('演示接口')
            ->generate();
    }
}
