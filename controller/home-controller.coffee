class HomeController

  get: (req, res) ->
    res.render('index')

module.exports = HomeController