var router = require('express').Router();
var exec = require('child_process').exec;

async function publicHostname() {
  return new Promise((resolve, reject) => {
    exec('curl http://169.254.169.254/latest/meta-data/public-hostname', (error, stdout, stderr) => resolve(stdout));
  });
};

// return a list of tags
router.get('/', async (req, res, next) => {
  const data = await publicHostname();

  return res.json({ 'public-hostname': data });
});

module.exports = router;
