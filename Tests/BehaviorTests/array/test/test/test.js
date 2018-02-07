var config = require("../config.js")

var Contract = artifacts.require("./" + config.contractName + ".sol");
var Interface = artifacts.require("./_Interface" + config.contractName + ".sol");
Contract.abi = Interface.abi

contract(config.contractName, function(accounts) {
  it("should read the value it writes to the first array", async function() {
    const instance = await Contract.deployed()
    let t;

    await instance.write(0, 4);
    await instance.write(1, 3);
    await instance.write(2, 4590);
    await instance.write(3, 304);
    assert.equal((await instance.value.call(0)).valueOf(), 4, "");
    t = await instance.value.call(1);
    assert.equal(t.valueOf(), 3, "");
    t = await instance.value.call(2);
    assert.equal(t.valueOf(), 4590, "");
    t = await instance.value.call(3);
    assert.equal(t.valueOf(), 304, "");
    await instance.write(2, 40);
    t = await instance.value.call(2);
    await assert.equal(t.valueOf(), 40, "");
  });

  it("should read the value it writes to the second array", async function() {
    const instance = await Contract.deployed();
    let t;

    await instance.write2(0, 40);
    await instance.write2(1, 48);
    await instance.write2(9, 12);

    await instance.write(0, 4);
    await instance.write(1, 5);

    t = await instance.value2.call(1);
    assert.equal(t.valueOf(), 48);

    t = await instance.value2.call(9);
    assert.equal(t.valueOf(), 12);

    t = await instance.value.call(0);
    assert.equal(t.valueOf(), 4);

    t = await instance.value.call(1);
    assert.equal(t.valueOf(), 5);
  });

  it("should correctly return valueBoth", async function() {
    const instance = await Contract.deployed();
    let t;

    await instance.write2(2, 40);
    await instance.write(2, 50);

    t = await instance.valueBoth.call(2);
    assert.equal(t.valueOf(), 90);
  });


  it("revert on out-of-bounds array accesses", async function() {
    const instance = await Contract.deployed();
    let t;

    try {
      await instance.write2(10, 40);
    } catch (e) {
      return
    }

    assert.fail()
  });
});

contract(config.contractName, function(accounts) {
  it("should correctly return numWrites", async function() {
    const instance = await Contract.deployed();
    let t;

    await instance.write2(2, 40);
    await instance.write(2, 50);

    t = await instance.numWrites.call();
    assert.equal(t.valueOf(), 2);
  });
});


