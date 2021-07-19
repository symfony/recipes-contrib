<?php

namespace App\CharacterGenerator;

use Pierstoval\Bundle\CharacterManagerBundle\Action\StepAction;
use Symfony\Component\HttpFoundation\Response;

class Step01 extends StepAction
{
    /**
     * {@inheritdoc}
     */
    public function execute(): Response
    {
        // Render and/or execute the current step right here.
        // You must return a `Response` object, like a controller would need to.
    }
}
