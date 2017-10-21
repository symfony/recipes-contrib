<?php

namespace App\Controller\User;

use App\Entity\User\PendingUser;
use MsgPhp\Domain\CommandBusInterface;
use MsgPhp\User\Command\ConfirmPendingUserCommand;
use MsgPhp\User\Infra\Uuid\UserId;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\ParamConverter;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session\Flash\FlashBagInterface;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;

final class ConfirmAccountController
{
    /**
     * @ParamConverter("pendingUser", options={"mapping": {"token": "token"}})
     */
    public function __invoke(
        PendingUser $pendingUser,
        FlashBagInterface $flashBag,
        UrlGeneratorInterface $urlGenerator,
        CommandBusInterface $commandBus
    ): Response
    {
        $commandBus->handle(new ConfirmPendingUserCommand($pendingUser->getToken(), new UserId()));
        $flashBag->add('success', sprintf('Hi, your account is confirmed. You can now login.'));

        return new RedirectResponse($urlGenerator->generate('login'));
    }
}
