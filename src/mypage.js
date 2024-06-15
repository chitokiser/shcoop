let contractAddress = {
  metbank: "0xB5D24E748a42fd27Cd57f8Acf1bd3C1d87ca3FFD",  //sutbnak
  metmarket: "0x87280638619c508967c42AE10c0c3E6d5d57f2c0" //sutrealmarket
    
  };
  let contractAbi = {
   
    metmarket: [
      "function buy(uint _mid) public",
      "function mid() public view returns (uint256)",
      "function tax() public view returns (uint256)",
      "function g1() public view virtual returns(uint256)",
      "function selladd(uint _mid,uint256 _init) public",
      "function getmainpass(uint _mid) external view returns (string memory)",
      "function getpass(uint256 _mid) external view returns (string memory)",  //관람자패스
      "function getmetainfo(uint _num) public view returns (uint256, uint256, string memory, uint256,uint8, address,address) ",
      "function charge(uint _pay) public",
      "function newmeta(uint _metanum,string memory _investor,uint256 _init,string memory _mainpass) public"
     ],
   
    metbank: [
      "function g1() public view virtual returns(uint256)",
      "function g6() public view virtual returns(uint256)",
      "function g7() public view virtual returns(uint256)",
      "function g8(address user) public view virtual returns(uint256)",
      "function g9(address user) public view returns(uint)",
      "function g10() public view virtual returns(uint256)",
      "function allow() public view returns(uint256)",
      "function sum() public view returns(uint256)",
      "function allowt(address user) public view returns(uint256)",
      "function g11() public view virtual returns(uint256)",
      "function getprice() public view returns (uint256)",
      "function gettime() external view returns (uint256)",
      "function withdraw() public ",
      "function buysut(uint _num) public returns(bool)",
      "function sellsut(uint num)public returns(bool)",
      "function getpay(address user) public view returns (uint256)",
      "function allowcation() public returns(bool) ",
      "function getlevel(address user) public view returns(uint) ",
      "function getmento(address user) public view returns(address) ",
      "function getagent(address user) public view returns(address) ",
      "function memberjoin(address _mento) public ",
      "function myinfo(address user) public view returns(uint,uint,uint,address,address,uint,uint)",
      "function levelup() public"

    ]


  };



  let MemberLogin = async () => {
    let userProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
    await window.ethereum.request({
      method: "wallet_addEthereumChain",
      params: [{
          chainId: "0xCC",
          rpcUrls: ["https://opbnb-mainnet-rpc.bnbchain.org"],
          chainName: "opBNB",
          nativeCurrency: {
              name: "BNB",
              symbol: "BNB",
              decimals: 18
          },
          blockExplorerUrls: ["https://opbnbscan.com"]
      }]
  });
    await userProvider.send("eth_requestAccounts", []);
    let signer = userProvider.getSigner();
    let cyamemContract = new ethers.Contract(contractAddress.metbank, contractAbi.metbank, signer);
    let mylev = parseInt(await cyamemContract.getlevel(await signer.getAddress()));
    let mymento = (await cyamemContract.getmento(await signer.getAddress()));  
    let levelexp = (2**mylev)*10000;
    let my = await cyamemContract.myinfo(await signer.getAddress());
    let myexp =  (await my[6]);
    let mybonus =  (await my[1]);
    document.getElementById("Mylev").innerHTML = (mylev);
    document.getElementById("Mylev2").innerHTML = (mylev);
    document.getElementById("Exp").innerHTML =  (myexp);
    document.getElementById("Expneeded").innerHTML = (levelexp);
    document.getElementById("Mypoint").innerHTML =  (mybonus/1e18).toFixed(4);
    document.getElementById("Mymento").innerHTML = (mymento);
    
    document.getElementById("LevelBar").style.width = `${myexp/levelexp*100}%`; // CHECK:: 소수점으로 나오는 것 같아 *100 했습니다. 

    let cutdefiContract = new ethers.Contract(contractAddress.cutdefiAddr, contractAbi.cutdefi, signer);
    let myfee = parseInt(await cutdefiContract.g18(await signer.getAddress()));
    let totalfee = parseInt(await cutdefiContract.g16(await signer.getAddress()));
    document.getElementById("Myfee").innerHTML=(myfee/1e18).toFixed(4);
    document.getElementById("Totalfee").innerHTML=(totalfee/1e18).toFixed(4);
  };

  let Levelup = async () => {
   
    let userProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
    await window.ethereum.request({
      method: "wallet_addEthereumChain",
      params: [{
          chainId: "0xCC",
          rpcUrls: ["https://opbnb-mainnet-rpc.bnbchain.org"],
          chainName: "opBNB",
          nativeCurrency: {
              name: "BNB",
              symbol: "BNB",
              decimals: 18
          },
          blockExplorerUrls: ["https://opbnbscan.com"]
      }]
  });
    await userProvider.send("eth_requestAccounts", []);
    let signer = userProvider.getSigner();

    let cyamemContract = new ethers.Contract(contractAddress.metbank, contractAbi.metbank, signer);
    try {
      await cyamemContract.levelup(); 
    } catch(e) {
      alert(e.data.message.replace('execution reverted: ',''))
    }
  
};




let Bonuswithdraw = async () => {
   
  let userProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
  await window.ethereum.request({
    method: "wallet_addEthereumChain",
    params: [{
        chainId: "0xCC",
        rpcUrls: ["https://opbnb-mainnet-rpc.bnbchain.org"],
        chainName: "opBNB",
        nativeCurrency: {
            name: "BNB",
            symbol: "BNB",
            decimals: 18
        },
        blockExplorerUrls: ["https://opbnbscan.com"]
    }]
});
  await userProvider.send("eth_requestAccounts", []);
  let signer = userProvider.getSigner();

  let cyamemContract = new ethers.Contract(contractAddress.metbank, contractAbi.metbank, signer);
  
  try {
    await cyamemContract. withdraw(); 
    //await cyabankContract.buycut(document.getElementById('buyAmount').value);
  } catch(e) {
    alert(e.data.message.replace('execution reverted: ',''))
  }

};


let Withdraw = async () => {
   
  let userProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
  await window.ethereum.request({
    method: "wallet_addEthereumChain",
    params: [{
        chainId: "0xCC",
        rpcUrls: ["https://opbnb-mainnet-rpc.bnbchain.org"],
        chainName: "opBNB",
        nativeCurrency: {
            name: "BNB",
            symbol: "BNB",
            decimals: 18
        },
        blockExplorerUrls: ["https://opbnbscan.com"]
    }]
});
  await userProvider.send("eth_requestAccounts", []);
  let signer = userProvider.getSigner();

  let cutdefiContract = new ethers.Contract(contractAddress.cutdefiAddr, contractAbi.cutdefi, signer);
  
  try {
    await cutdefiContract. withdraw(); //cutdefi 멘토수당
    //await cyabankContract.buycut(document.getElementById('buyAmount').value);
  } catch(e) {
    alert(e.data.message.replace('execution reverted: ',''))
  }

};

let Mentolevelup = async () => {
   
  let userProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
  await window.ethereum.request({
    method: "wallet_addEthereumChain",
    params: [{
        chainId: "0xCC",
        rpcUrls: ["https://opbnb-mainnet-rpc.bnbchain.org"],
        chainName: "opBNB",
        nativeCurrency: {
            name: "BNB",
            symbol: "BNB",
            decimals: 18
        },
        blockExplorerUrls: ["https://opbnbscan.com"]
    }]
});
  await userProvider.send("eth_requestAccounts", []);
  let signer = userProvider.getSigner();

  let cyamemContract = new ethers.Contract(contractAddress.cyamemAddr, contractAbi.cyamem, signer);
  
  try {
    await cyamemContract. mentolevelup(); //cat 개수 필요
    //await cyabankContract.buycut(document.getElementById('buyAmount').value);
  } catch(e) {
    alert(e.data.message.replace('execution reverted: ',''))
  }

};


let Charge = async () => {
  let userProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
  await window.ethereum.request({
    method: "wallet_addEthereumChain",
    params: [{
        chainId: "0xCC",
        rpcUrls: ["https://opbnb-mainnet-rpc.bnbchain.org"],
        chainName: "opBNB",
        nativeCurrency: {
            name: "BNB",
            symbol: "BNB",
            decimals: 18
        },
        blockExplorerUrls: ["https://opbnbscan.com"]
    }]
});
  await userProvider.send("eth_requestAccounts", []);
  let signer = userProvider.getSigner();

  let meta5Contract = new ethers.Contract(contractAddress.metmarket, contractAbi.metmarket, signer);

  try {
    await meta5Contract.charge(document.getElementById('chargeAmount').value);
  } catch(e) {
    alert(e.data.message.replace('execution reverted: ',''))
  }
};