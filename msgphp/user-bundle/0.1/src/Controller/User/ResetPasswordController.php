<?php

namespace App\Controller\User;

use App\Entity\User\User;
use App\Form\User\ResetPasswordType;
use MsgPhp\Domain\CommandBusInterface;
use MsgPhp\User\Command\ResetUserPasswordCommand;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\ParamConverter;
use Symfony\Component\Form\FormFactoryInterface;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session\Flash\FlashBagInterface;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Symfony\Component\Security\Core\Authentication\Token\Storage\TokenStorageInterface;
use Twig\Environment;

final class ResetPasswordController
{
    /**
     * @ParamConverter("user", options={"mapping": {"token": "passwordResetToken"}})
     */
    public function __invoke(
        User $user,
        Request $request,
        FormFactoryInterface $formFactory,
        FlashBagInterface $flashBag,
        UrlGeneratorInterface $urlGenerator,
        TokenStorageInterface $tokenStorage,
        Environment $twig,
        CommandBusInterface $commandBus
    ): Response
    {
        $form = $formFactory->createNamed('', ResetPasswordType::class);

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $data = $form->getData();

            $commandBus->handle(new ResetUserPasswordCommand($user->getPasswordResetToken(), $data['password']));
            $flashBag->add('success', 'Hi, we\'ve reset your password. Please login again.');
            $tokenStorage->setToken(null);

            return new RedirectResponse($urlGenerator->generate('index'));
        }

        return new Response($twig->render('User/reset_password.html.twig', [
            'form' => $form->createView(),
        ]));
    }
}
