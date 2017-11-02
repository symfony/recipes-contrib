<?php

namespace App\Security;

use Symfony\Component\Form\Extension\Core\Type\HiddenType;
use Symfony\Component\Form\Extension\Core\Type\PasswordType;
use Symfony\Component\Form\FormFactoryInterface;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Symfony\Component\Security\Core\Validator\Constraints\UserPassword;
use Twig\Environment;

final class UserPasswordConfirmation
{
    private $twig;
    private $formFactory;
    private $urlGenerator;

    public function __construct(Environment $twig, FormFactoryInterface $formFactory, UrlGeneratorInterface $urlGenerator)
    {
        $this->twig = $twig;
        $this->formFactory = $formFactory;
        $this->urlGenerator = $urlGenerator;
    }

    public function confirm(Request $request): ?Response
    {
        if (null === $session = $request->getSession()) {
            throw new \LogicException('Session not available.');
        }

        if ($session->has($hash = md5($request->getUriForPath($request->getRequestUri())))) {
            $session->remove($hash);

            return null;
        }

        $referer = (null !== $route = $request->attributes->get('_route'))
            ? $this->urlGenerator->generate($route, $request->attributes->get('_route_params', []), UrlGeneratorInterface::ABSOLUTE_URL)
            : $request->headers->get('referer');

        $form = $this->formFactory->createNamedBuilder($hash)
            ->add('password', PasswordType::class, [
                'required' => true,
                'constraints' => [new UserPassword()],
            ])
            ->add('referer', HiddenType::class, [
                'data' => $referer,
            ])
            ->getForm();

        $form->handleRequest($request);

        if ($form->isSubmitted()) {
            if ($form->isValid()) {
                $session->set($hash, '1');

                return new RedirectResponse($request->getRequestUri());
            }

            $referer = $form->get('referer')->getData();
        }

        if (null === $referer || $hash === md5($referer)) {
            throw new BadRequestHttpException('Unable to confirm current request.');
        }

        return new Response($this->twig->render('confirm_password.html.twig', [
            'form' => $form->createView(),
            'cancelUrl' => $referer,
        ]));
    }
}
