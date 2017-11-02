<?php

namespace App\Controller\User;

use App\Form\User\ForgotPasswordType;
use MsgPhp\Domain\CommandBusInterface;
use MsgPhp\User\Command\RequestUserPasswordCommand;
use MsgPhp\User\Infra\Security\SecurityUserFactory;
use Symfony\Component\Form\FormFactoryInterface;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session\Flash\FlashBagInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Twig\Environment;

final class ForgotPasswordController
{
    public function __invoke(
        SecurityUserFactory $securityUser,
        Request $request,
        FormFactoryInterface $formFactory,
        FlashBagInterface $flashBag,
        UrlGeneratorInterface $urlGenerator,
        Environment $twig,
        CommandBusInterface $commandBus
    ): Response
    {
        if ($securityUser->isAuthenticated()) {
            return new RedirectResponse($urlGenerator->generate('my_account'));
        }

        $form = $formFactory->createNamed('', ForgotPasswordType::class);

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $data = $form->getData();

            $commandBus->handle(new RequestUserPasswordCommand($data['email']));
            $flashBag->add('success', sprintf('Hi %s, we\'ve send you a reset link.', $data['email']));

            return new RedirectResponse($urlGenerator->generate('index'));
        }

        return new Response($twig->render('User/forgot_password.html.twig', [
            'form' => $form->createView(),
        ]));
    }
}
