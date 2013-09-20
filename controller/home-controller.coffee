class HomeController

  get: (req, res) ->
    errMessage = (req.flash 'error')?[0]
    console.log errMessage
    res.render 'index', {error: errMessage }

module.exports = HomeController