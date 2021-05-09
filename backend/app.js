var Web3 = require('web3');
var net = require('net');
var web3 = new Web3('/Users/stephen.he/eth/data/01/geth.ipc', net);

const abi = require('../../xp-solidity/contracts/artifacts/Xp_metadata.json').output.abi;
const contract = new web3.eth.Contract(abi, '0xeEF537eB8272a38eA42cC67527Bc5CC34FFb8724', {
  from: '0x42D683444B053F15CFcf3D6B28e2F8125A9E1117',
});

function proposeAndCertify() {
  var from = Date.now();
  return new Promise(function (resolve, reject) {
    contract.methods.propose('0x42D683444B053F15CFcf3D6B28e2F8125A9E1117', 'a', 'b').send()
    .on('sent', function () {
      console.log('sentp', Date.now() - from);
    })
    .on('receipt', function (r) {
      console.log('receiptp', Date.now() - from, r.gasUsed);
    })
    .then(function () {
      var from = Date.now();
      contract.methods.certify('0x42D683444B053F15CFcf3D6B28e2F8125A9E1117', 'b').send()
      .on('sent', function () {
        console.log('sentc', Date.now() - from);
      })
      .on('receipt', function (r) {
        console.log('receiptc', Date.now() - from, r.gasUsed);
      })
      .then(function () {
        resolve();
      });
    });
  });
}

function grant() {
  var from = Date.now();
  // console.log('grant', Date.now());
  return new Promise(function (resolve, reject) {
    contract.methods.grant('0x42D683444B053F15CFcf3D6B28e2F8125A9E1117', 'enc').send().then((res) => {
      // console.log(res);
      console.log('grant', Date.now() - from, res.gasUsed);
      resolve();
    });
  })

  // contract.once('PermissionGranted', {
  //   fromBlock: 0
  // }, function (error, event) {
  //   console.log(error);
  //   console.log(event);
  //   console.log('event', Date.now() - from);
  // });
}

(async function () {
  for (i = 0; i < 1000; i++) {
    console.log(i);
    // await proposeAndCertify();
    await grant();
  }
})();

