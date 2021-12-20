<?php

namespace App\Controller\Admin\EasyBlock;

use Adeliom\EasyBlockBundle\Controller\BlockCrudController as BaseBlockCrudController;
use App\Entity\EasyBlock\Block;

class BlockCrudController extends BaseBlockCrudController
{
    public static function getEntityFqcn(): string
    {
        return Block::class;
    }
}
