<?php

namespace App\Controller\Admin\EasyFaq;

use Adeliom\EasyFaqBundle\Controller\CategoryCrudController as BaseCategoryCrudController;
use App\Entity\EasyFaq\Category;

class CategoryCrudController extends BaseCategoryCrudController
{

    public static function getEntityFqcn(): string
    {
        return Category::class;
    }

}
