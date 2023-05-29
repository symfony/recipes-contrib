<?php

namespace App\Controller;

use MercurySeries\Bundle\InertiaMakerBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class PagesController extends AbstractController
{
    #[Route('/', name: 'app_home', methods: ['GET'], options: ['expose' => true])]
    public function home(): Response
    {
        return $this->inertiaRender('Home', ['name' => 'John Doe']);
    }

    #[Route('/about-us', name: 'app_about', methods: ['GET'], options: ['expose' => true])]
    public function about(): Response
    {
        return $this->inertiaRender('About');
    }
}
