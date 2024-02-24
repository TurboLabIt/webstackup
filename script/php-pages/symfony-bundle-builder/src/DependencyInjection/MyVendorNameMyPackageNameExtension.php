<?php
/**
 * 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/script/php-pages/symfony-bundle-builder/src/DependencyInjection/MyVendorNameMyPackageNameExtension.php
 *
 * 📚 Usage example (customize with your own):
 *
 * - MyVendorName   ➡ TurboLabIt
 * - MyPackageName  ➡ BaseCommand
 *
 * 💡 "Replace all" the above and you're done!
 *
 * Expected result:
 *
 * - filename   ➡ TurboLabItBaseCommandExtension.php
 * - namespace  ➡ TurboLabIt\BaseCommandBundle\DependencyInjection
 * - class      ➡ TurboLabItBaseCommandExtension
 *
 * ✅ You're done && ready to go here!
 *
 * 📚 Resources:
 *
 * - https://symfony.com/doc/current/bundles/extension.html#creating-an-extension-class
 */
namespace MyVendorName\MyPackageNameBundle\DependencyInjection;

use Symfony\Component\DependencyInjection\Extension\Extension;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Loader\YamlFileLoader;
use Symfony\Component\Config\FileLocator;


class MyVendorNameMyPackageNameExtension extends Extension
{
    public function load(array $configs, ContainerBuilder $container): void
    {
        $loader = new YamlFileLoader($container, new FileLocator(__DIR__.'/../../config') );
        $loader->load('services.yaml');
    }
}
