<?php

namespace App\Controller\User;

use App\EventSubscriber\SendEmailConfirmationUrlToUser;
use App\Form\User\AddSecondaryEmailType;
use App\Form\User\ChangeEmailType;
use App\Form\User\ChangePasswordType;
use App\Security\PasswordConfirmation;
use MsgPhp\Domain\CommandBusInterface;
use MsgPhp\User\Command\AddUserSecondaryEmailCommand;
use MsgPhp\User\Command\ChangeUserPasswordCommand;
use MsgPhp\User\Command\DeleteUserSecondaryEmailCommand;
use MsgPhp\User\Command\MarkUserSecondaryEmailPrimaryCommand;
use MsgPhp\User\Command\SetUserPendingPrimaryEmailCommand;
use MsgPhp\User\Infra\Security\SecurityUserFactory;
use MsgPhp\User\Repository\UserSecondaryEmailRepositoryInterface;
use Symfony\Component\Form\FormFactoryInterface;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session\Flash\FlashBagInterface;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Symfony\Component\Security\Core\Authentication\Token\Storage\TokenStorageInterface;
use Twig\Environment;

final class MyAccountController
{
    public function __invoke(
        SecurityUserFactory $securityUser,
        TokenStorageInterface $tokenStorage,
        Request $request,
        FormFactoryInterface $formFactory,
        FlashBagInterface $flashBag,
        UrlGeneratorInterface $urlGenerator,
        Environment $twig,
        CommandBusInterface $commandBus,
        UserSecondaryEmailRepositoryInterface $userSecondaryEmailRepository,
        SendEmailConfirmationUrlToUser $sendEmailConfirmationUrlToUser,
        PasswordConfirmation $passwordConfirmation
    ): Response
    {
        if (!$securityUser->isAuthenticated()) {
            return new RedirectResponse($urlGenerator->generate('login'));
        }

        // change primary e-mail
        $emailForm = $formFactory->create(ChangeEmailType::class);

        $emailForm->handleRequest($request);

        if ($emailForm->isSubmitted() && $emailForm->isValid()) {
            $data = $emailForm->getData();

            $commandBus->handle(new SetUserPendingPrimaryEmailCommand($securityUser->getUserId(), $data['email']));
            $flashBag->add('success', 'We\'ve send you a confirmation link.');

            return new RedirectResponse($urlGenerator->generate('my_account'));
        }

        // cancel pending primary email
        if ($request->query->getBoolean('cancel-email')) {
            if (null !== $confirmResponse = $passwordConfirmation->confirm($request)) {
                return $confirmResponse;
            }

            $commandBus->handle(new SetUserPendingPrimaryEmailCommand($securityUser->getUserId(), null));
            $flashBag->add('success', 'Cancelled pending primary e-mail.');

            return new RedirectResponse($urlGenerator->generate('my_account'));
        }

        // add secondary email
        $secondaryEmailForm = $formFactory->create(AddSecondaryEmailType::class);

        $secondaryEmailForm->handleRequest($request);

        if ($secondaryEmailForm->isSubmitted() && $secondaryEmailForm->isValid()) {
            $data = $secondaryEmailForm->getData();

            $commandBus->handle(new AddUserSecondaryEmailCommand($securityUser->getUserId(), $data['email']));
            $flashBag->add('success', 'We\'ve send you a confirmation link.');

            return new RedirectResponse($urlGenerator->generate('my_account'));
        }

        // mark secondary e-mail primary
        if ($primaryEmail = $request->query->get('primary-email')) {
            if (null !== $confirmResponse = $passwordConfirmation->confirm($request)) {
                return $confirmResponse;
            }

            $commandBus->handle(new MarkUserSecondaryEmailPrimaryCommand($securityUser->getUserId(), $primaryEmail));

            $currentSecondaryEmail = $userSecondaryEmailRepository->find($securityUser->getUserId(), $primaryEmail);
            if ($currentSecondaryEmail->getConfirmedAt()) {
                $flashBag->add('success', 'We\'ve changed your primary e-mail. Please login again.');
                $tokenStorage->setToken(null);

                return new RedirectResponse($urlGenerator->generate('login'));
            }

            $flashBag->add('success', sprintf('Marked secondary e-mail "%s" as pending primary.', $primaryEmail));

            return new RedirectResponse($urlGenerator->generate('my_account'));
        }

        // delete secondary e-mail
        if ($deleteEmail = $request->query->get('delete-email')) {
            if (null !== $confirmResponse = $passwordConfirmation->confirm($request)) {
                return $confirmResponse;
            }

            $commandBus->handle(new DeleteUserSecondaryEmailCommand($securityUser->getUserId(), $deleteEmail));
            $flashBag->add('success', sprintf('Deleted secondary e-mail "%s".', $deleteEmail));

            return new RedirectResponse($urlGenerator->generate('my_account'));
        }

        // change password
        $passwordForm = $formFactory->create(ChangePasswordType::class);

        $passwordForm->handleRequest($request);

        if ($passwordForm->isSubmitted() && $passwordForm->isValid()) {
            $data = $passwordForm->getData();

            $commandBus->handle(new ChangeUserPasswordCommand($securityUser->getUserId(), $data['password']));
            $flashBag->add('success', 'We\'ve reset your password. Please login again.');
            $tokenStorage->setToken(null);

            return new RedirectResponse($urlGenerator->generate('login'));
        }

        // send secondary / pending primary email confirmation link
        if ($confirmEmail = $request->query->get('confirm-email')) {
            $currentSecondaryEmail = $userSecondaryEmailRepository->find($securityUser->getUserId(), $confirmEmail);
            if (!$currentSecondaryEmail->getConfirmedAt()) {
                $sendEmailConfirmationUrlToUser->notify($currentSecondaryEmail);
                $flashBag->add('success', 'We\'ve re-send you a confirmation link.');
            }

            return new RedirectResponse($urlGenerator->generate('my_account'));
        }

        // render view
        return new Response($twig->render('User/my_account.html.twig', [
            'emailForm' => $emailForm->createView(),
            'secondaryEmails' => $userSecondaryEmailRepository->findAllByUserId($securityUser->getUserId()),
            'secondaryEmailForm' => $secondaryEmailForm->createView(),
            'passwordForm' => $passwordForm->createView(),
        ]));
    }
}
