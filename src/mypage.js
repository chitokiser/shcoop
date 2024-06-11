let contractAddress = {
  metbank: "0x0ef1043e59a7f38aC1acBeB04CcA9714C4eb0098",
  metmarket: "0xd9fC1B43BD9F37c8BAFC666CA88A74Ad8aDa2627" //mt5
    
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
      "function buymut(uint _num) public returns(bool)",
      "function sellmut(uint num)public returns(bool)",
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


  // 멘토데이타 입력
  var dataArray = [
    "0xe31b9c8f32081D0a61Fa1268d6cfC78207cb75F8",
    "0xd0b8E0Dbb658d24cA59aa7108f582daD98Dd2A27",
    "0x97665586235b76f6Fd34fDD1db675C2D129A6824"
   
 
  ];
  
  // Function to select and display random data
  function displayRandomData() {
    // Select a random item from the array
    var randomIndex = Math.floor(Math.random() * dataArray.length);
    var randomData = dataArray[randomIndex];
  
    // Display the random data
    document.getElementById("randomData").textContent = randomData;
  }
  
  // Event listener for button click
  document.getElementById("randomButton").addEventListener("click", displayRandomData);
  
  
  function autoFillMentoAddress() {
    // Retrieve the printed mentoaddress
    var mentoaddress = document.getElementById('randomData').textContent;
  
    document.getElementById('mentoaddress').value = mentoaddress;
  }
  
  document.getElementById("randomButton").addEventListener("click", autoFillMentoAddress);
  

  let Memberjoin = async () => {
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
      await cyamemContract.memberjoin(document.getElementById('mentoaddress').value);
    } catch(e) {
      alert(e.data.message.replace('execution reverted: ',''))
    }
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