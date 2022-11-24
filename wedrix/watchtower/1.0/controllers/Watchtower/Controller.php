<?php

declare(strict_types=1);

namespace App\Controller\Watchtower;

use App\WatchtowerExecutor;
use GraphQL\Error\DebugFlag;
use Psr\Container\ContainerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

final class Controller extends AbstractController
{
    #[Route('/graphql.json', name: 'graphql')]
    public function index(
        Request $request,
        WatchtowerExecutor $executor,
        ContainerInterface $parameterBag
    ): Response
    {
        $input = json_decode($request->getContent(), true);

        $response = new Response();

        $response->setContent(
            content: is_string(
                $responseBody = json_encode(
                    $executor->getInstance()
                            ->executeQuery(
                                source: $input['query'] ?? '',
                                rootValue: [],
                                contextValue: [
                                    'request' => $request, 
                                    'response' => $response
                                ],
                                variableValues: $input['variables'] ?? null,
                                operationName: $input['operationName'] ?? null,
                                validationRules: null
                            )
                            ->toArray(
                                debug: ($parameterBag->get('kernel.environment') === 'dev')
                                    ? DebugFlag::INCLUDE_DEBUG_MESSAGE | DebugFlag::INCLUDE_TRACE
                                    : DebugFlag::NONE,
                            )
                )
            ) 
            ? $responseBody
            : throw new \Exception("Unable to encode GraphQL result")
        )
        ->headers
        ->set('Content-Type', 'application/json; charset=utf-8');

        return $response;
    }
}
