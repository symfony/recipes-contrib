<?php

namespace App\Controller\Admin\EasyPage;

use Adeliom\EasyPageBundle\Controller\PageCrudController as BasePageCrudController;
use App\Entity\EasyPage\Page;

class PageCrudController extends BasePageCrudController
{
    public static function getEntityFqcn(): string
    {
        return Page::class;
    }
}
