// A helper function to dynamically require modules from the project's folder
const reqLocal = (moduleName) => require(require.resolve(moduleName, { paths: [process.cwd()] }));

const MiniCssExtractPlugin = reqLocal("mini-css-extract-plugin");
const CssMinimizerPlugin = reqLocal("css-minimizer-webpack-plugin");

const path = require('path');

// Define base source paths
const jsPath = './assets/js';
const cssPath = './assets/scss';

module.exports = {

    // you can override this via CLI using `webpack --mode development`
    mode: 'production',

    entry: {
        'main': [
            `${jsPath}/main.js`,
            `${cssPath}/style.scss`,
        ]
    },

    output: {
        // CRITICAL: Set the absolute path to a dedicated, isolated build folder.
        path: path.resolve(process.cwd(), 'assets/build'),

        // Output inside the build folder (e.g., assets/build/js/main.min.a1b2c3d4.js)
        // Using contenthash ensures only modified files get new cache-busting names.
        filename: 'js/[name].min.[contenthash].js',

        // Webpack 5 Native: Safely wipes ONLY the 'assets/build' directory before compiling.
        clean: true,
    },

    plugins: [
        new MiniCssExtractPlugin({
            // Output relative to the new output.path defined above
            filename: 'css/[name].min.[contenthash].css',
        }),
    ],

    module: {
        rules: [
            // JavaScript Transpilation
            {
                test: /\.(js|jsx)$/,
                exclude: /node_modules/,
                loader: 'babel-loader'
            },
            // SCSS Compilation
            {
                test: /\.(sass|scss)$/,
                use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader']
            },
            // Webpack 5 Native Asset Modules for Fonts
            {
                test: /\.(woff|woff2|eot|ttf|otf)$/i,
                type: 'asset/resource',
                generator: {
                    // Outputs to assets/build/fonts/
                    filename: 'fonts/[name][ext]',
                }
            }
        ]
    },

    externals: {
        // Keeps WordPress's native jQuery out of your compiled bundle
        "jquery": "jQuery"
    },

    optimization: {
        minimizer: [
            // The '...' tells Webpack 5 to keep its built-in JS minimizer (TerserPlugin)
            `...`,
            // Add CSS minification alongside it
            new CssMinimizerPlugin(),
        ]
    },
};
