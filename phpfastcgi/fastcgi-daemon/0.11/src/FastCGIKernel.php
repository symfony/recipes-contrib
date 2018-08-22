<?php

namespace App;

use PHPFastCGI\FastCGIDaemon\Http\RequestInterface;
use PHPFastCGI\FastCGIDaemon\KernelInterface as PHPFastCGIKernel;
use Symfony\Component\HttpKernel\KernelInterface;
use Symfony\Component\HttpKernel\TerminableInterface;

class FastCGIKernel implements PHPFastCGIKernel
{
    private $kernel;

    public function __construct(KernelInterface $kernel)
    {
        $this->kernel = $kernel;
    }

    public function handleRequest(RequestInterface $request)
    {
        $this->kernel->boot(); 

        $symfonyRequest = $request->getHttpFoundationRequest();
        $symfonyResponse = $this->kernel->handle($symfonyRequest);

        if ($this->kernel instanceof TerminableInterface) {
            $this->kernel->terminate($symfonyRequest, $symfonyResponse);
        }

        return $symfonyResponse;
    }
}

