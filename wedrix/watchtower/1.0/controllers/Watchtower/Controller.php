<?php

declare(strict_types=1);

namespace App\Controller\Watchtower;

use Doctrine\ORM\EntityManagerInterface;
use GraphQL\Error\DebugFlag;
use Psr\Container\ContainerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Wedrix\Watchtower\Executor;

final class Controller extends AbstractController
{
    #[Route('/graphql.json', name: 'graphql')]
    public function index(
        Request $request,
        EntityManagerInterface $entityManager,
        ContainerInterface $parameterBag
    ): Response
    {
        $input = json_decode($request->getContent(), true);

        $response = new Response();

        $response->setContent(
            content: is_string(
                $responseBody = json_encode(
                    (
                        new Executor(
                            entityManager: $entityManager,
                            schemaFileDirectory: ($projectDir = $this->getParameter('kernel.project_dir')) . '/config/graphql/schema.graphql',
                            schemaCacheFileDirectory: $projectDir . '/var/cache/graphql/schema.graphql',
                            cachesTheSchema: $parameterBag->get('kernel.environment') !== 'dev',
                            pluginsDirectory: $projectDir . '/config/graphql/plugins',
                            scalarTypeDefinitionsDirectory: $projectDir . '/config/graphql/scalar_type_definitions'
                        )
                    )
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
