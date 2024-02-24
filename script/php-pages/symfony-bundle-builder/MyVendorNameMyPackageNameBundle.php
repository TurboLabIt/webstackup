<?php
/**
 * 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/script/php-pages/symfony-bundle-builder/MyVendorNameMyPackageNameBundle.php
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
 * - filename           ➡ TurboLabItBaseCommandBundle.php
 * - namespace          ➡ TurboLabIt\BaseCommandBundle
 * - class              ➡ TurboLabItBaseCommandBundle
 * - in composer.json   ➡ "autoload": {"psr-4": {"TurboLabIt\\BaseCommandBundle\\": "src/"}},
 * - in composer.json   ➡ "autoload-dev": {"psr-4": {"TurboLabIt\\BaseCommandBundle\\Tests\\": "tests/"}},
 * - in services.yaml   ➡ TurboLabIt\BaseCommandBundle\Service\MyService
 *
 * ✅ You're done && ready to go here!
 *
 * 📚 Resources:
 *
 * - https://symfony.com/doc/current/bundles.html
 * - https://symfonycasts.com/screencast/symfony-bundle/bundle-directory
 */
namespace MyVendorName\MyPackageNameBundle;

use Symfony\Component\HttpKernel\Bundle\AbstractBundle;


class MyVendorNameMyPackageNameBundle extends AbstractBundle {}

