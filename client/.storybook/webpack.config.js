require('coffee-script/register')
var _ = require('lodash')
var ProgressBarPlugin = require('progress-bar-webpack-plugin')
var WebpackNotifierPlugin = require('webpack-notifier')

var clientConfig = require('../webpack.config')
var customConfig = _.pick(clientConfig, [
  'module',
  'resolve',
  'stylus'
])

customConfig = _.assign({}, customConfig, {
  plugins: [
    new ProgressBarPlugin({ format: ' client: [:bar] :percent ', width: 1024 }),
    new WebpackNotifierPlugin({ title: 'Component lab' })
  ]
})

console.log({
  c: customConfig.resolve
})

module.exports = customConfig


