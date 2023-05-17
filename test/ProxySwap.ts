import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { PancakeRouter__factory } from "../typechain-types";
import { Token } from "graphql";

const approveMax = '115792089237316195423570985008687907853269984665640564039457584007913129639935'

describe("ProxySwap", function () {
  async function advanceBlockTo(blockNumber: number) {
    for (let i = await ethers.provider.getBlockNumber(); i < blockNumber; i++) {
      await advanceBlock();
    }
  }

  async function _hash(
    tokenAddress: string,
    id: number,
    ownerAddress: string,
    blocknumber?: number
  ) {
    let bn = await ethers.provider.getBlockNumber();

    let hash = await ethers.utils.solidityKeccak256(
      ["uint256", "address", "uint256", "address"],
      [blocknumber ?? bn, tokenAddress, id, ownerAddress]
    );
    return hash;
  }

  async function advanceBlock() {
    return ethers.provider.send("evm_mine", []);
  }

  async function deployContract() {
    // Contracts are deployed using the first signer/account by default
    const [ownerAccount, account1, account2] = await ethers.getSigners();

    const wbnb = await ethers.getContractFactory("WBNB");

    const Wbnb = await wbnb.deploy();

    const factory = await ethers.getContractFactory("PancakeFactory");

    const Factory = await factory.deploy(ownerAccount.address);

    const router = await ethers.getContractFactory("PancakeRouter");

    const Router = await router.deploy(Factory.address, Wbnb.address);

    const tokenA = await ethers.getContractFactory("TestToken");
    const TokenA = await tokenA.deploy('TokenA', 'TA', "1000000000000000000000000000", 18);
    const tokenB = await ethers.getContractFactory("TestToken");
    const TokenB = await tokenB.deploy('TokenB', 'TB', "1000000000000000000000000000", 18);

    const blockNumber = await ethers.provider.getBlockNumber();
    const block = await ethers.provider.getBlock(blockNumber);
    const blockTimestamp = block.timestamp;

    // Init actions
    await Factory.createPair(Wbnb.address, TokenB.address);
    await Factory.createPair(Wbnb.address, TokenA.address);

    const proxy = await ethers.getContractFactory("PancakeSwapProxy");

    const Proxy = await proxy.deploy(Router.address);


    await TokenA.approve(Router.address, approveMax);
    await TokenB.approve(Router.address, approveMax);

    await Router.addLiquidity(
      TokenB.address,
      TokenA.address,
      "10000000000000000000000000000000", // amount of TokenA
      "10000000000000000000000000000000", // amount of TokenB
      "10000000000000000000", // min amount of LP tokens
      "10000000000000000000", // min amount of LP tokens
      ownerAccount.address,
      Math.floor(Date.now()) + 3600
    );

  

    return { blockNumber, blockTimestamp, Router, Factory, Wbnb, TokenA, TokenB, Proxy, ownerAccount,  account1, account2 };
  }

  describe("Deployment", function () {

    it("Should able to swap", async function () {
      const {blockNumber, blockTimestamp, Router, Factory, Wbnb, TokenA, TokenB, Proxy, ownerAccount, account1, account2 } = await loadFixture(deployContract);
  
      const swap = await Router.swapExactTokensForTokens(
        "100000000000000000000000000000", // amount of TokenA
        "10000000000000000000000000000", // amount of TokenB
        [TokenA.address, TokenB.address],
        ownerAccount.address,
        Math.floor(Date.now()) + 3600
      );
  
      expect(true).to.equal(true);
  
    });


    it("Should able to Approve", async function () {
      const {blockNumber, blockTimestamp, Router, Factory, Wbnb, TokenA, TokenB, Proxy, ownerAccount, account1, account2 } = await loadFixture(deployContract);
  
      await TokenA.transfer(Proxy.address, "100000000000000000000000000000");

      await Proxy.approve(TokenA.address);
  
      expect(true).to.equal(true);
  
    });


    it("Should able to Trade with swapWithProxy", async function () {
      const {blockNumber, blockTimestamp, Router, Factory, Wbnb, TokenA, TokenB, Proxy, ownerAccount, account1, account2 } = await loadFixture(deployContract);
  
      await TokenA.transfer(Proxy.address, "100000000000000000000000000000");

      await Proxy.approve(TokenA.address);

      const buy = await Proxy.safuBuy(
        "100000000000000000000000000000",
        '10000000000000000000000000000',
        [TokenA.address, TokenB.address],
      );

      let ProxyBalanceA = await TokenA.balanceOf(Proxy.address);
      let ProxyBalanceB = await TokenB.balanceOf(Proxy.address);
  
      expect(ProxyBalanceA).to.equal('0');
      expect(ProxyBalanceB).to.equal('98764820911408698235104829327');

      const sell = await Proxy.safuSell(
        ProxyBalanceB.toString(),
        '10000000000000000000000000000',
        [TokenB.address, TokenA.address],
      );

       ProxyBalanceA = await TokenA.balanceOf(Proxy.address);
       ProxyBalanceB = await TokenB.balanceOf(Proxy.address);
  
      expect(ProxyBalanceA).to.equal('99505544859550914677031370548');
      expect(ProxyBalanceB).to.equal('0');
  
    });


    it("WithDraw Token Balance", async function () {
      const {blockNumber, blockTimestamp, Router, Factory, Wbnb, TokenA, TokenB, Proxy, ownerAccount, account1, account2 } = await loadFixture(deployContract);
  
      await TokenA.transfer(Proxy.address, "100000000000000000000000000000");

      await ownerAccount.sendTransaction({
        to: Proxy.address,
        value: ethers.utils.parseEther("1.0"),
      });

      let proxyBalance = await ethers.provider.getBalance(Proxy.address);

      expect(proxyBalance).to.equal(ethers.utils.parseEther("1.0"));

      await Proxy.withdrawBalance();

      proxyBalance = await ethers.provider.getBalance(Proxy.address);

      expect(proxyBalance).to.equal(ethers.utils.parseEther("0"));

      await Proxy.withdrawAll(TokenA.address);

      let ProxyBalanceA = await TokenA.balanceOf(Proxy.address);

      expect(ProxyBalanceA).to.equal('0');

  
    });

  });





});
