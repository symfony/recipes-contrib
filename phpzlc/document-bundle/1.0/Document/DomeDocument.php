<?php

namespace App\Document;

use PHPZlc\Document\Document;

class DomeDocument extends Document
{
    public function domeAction()
    {
        $this->add()
            ->setTitle('演示接口')
            ->setUrl('/dome')
            ->setReturnType('html')
            ->setReturn('演示接口')
            ->generate();
    }
}
