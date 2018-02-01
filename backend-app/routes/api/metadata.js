var router = require('express').Router();
var exec = require('child_process').exec;

async function publicHostname() {
  return new Promise((resolve, reject) => {
    exec('curl http://169.254.169.254/latest/meta-data/public-hostname', (error, stdout, stderr) => resolve(stdout));
  });
};

async function publicIPv4() {
  return new Promise((resolve, reject) => {
    exec('curl http://169.254.169.254/latest/meta-data/public-ipv4', (error, stdout, stderr) => resolve(stdout));
  });
};

// return a list of tags
router.get('/', async (req, res, next) => {
  const [ hostname, ip ] = await Promise.all([publicHostname(), publicIPv4()]);

  return res.json({ 'public-hostname': hostname, 'public-ipv4': ip });
});

module.exports = router;
