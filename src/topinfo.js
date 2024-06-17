 
      const cA = {
        cyadexAddr: "0x3900609f4b3C635ae1cFC84F4f86eF7166c6139e",
        cyamemAddr: "0x3Fa37ba88e8741Bf681b911DB5C0F9d6DF99046f",   
        mutbankAddr:"0x0ef1043e59a7f38aC1acBeB04CcA9714C4eb0098",  //MUTBANK
        erc20: "0xFA7A4b67adCBe60B4EFed598FA1AC1f79becf748"
      };
      const cB = {
        cyadex: [
          "function getprice() public view returns(uint256)",
          "function balance() public view returns(uint256)",
          "function cyabalances() public view returns(uint256)",
          "function buy() payable public",
          "function sell(uint256 num) public"
        ],
        cyamem: [
          "function sum() public view returns(uint256)",
          "function catbal() public view returns(uint256)"
        ],

        mutbank: [
        "function memberjoin(address _mento) public ",
        ],
        erc20: [
          "function approve(address spender, uint256 amount) external returns (bool)",
          "function allowance(address owner, address spender) external view returns (uint256)"
        ]
      };

      const topData= async () => {
        

         // BNB Price
const responseBinanceTicker = await axios.get('https://api.binance.com/api/v3/ticker/price?symbol=BNBUSDT');
const bnbPrice = parseFloat(responseBinanceTicker.data.price);
document.getElementById("bPrice").innerHTML=bnbPrice.toFixed(4);
document.getElementById("cPrice2").innerHTML=(1/bnbPrice).toFixed(4);


        // ethers setup
        let provider = new ethers.providers.JsonRpcProvider('https://opbnb-mainnet-rpc.bnbchain.org');
        let cyadexContract = new ethers.Contract(cA.cyadexAddr,cB.cyadex, provider); 
        let dexBal = await cyadexContract.balance();
        document.getElementById("Tvl").innerHTML=  parseFloat(dexBal/1e18).toFixed(4); 
          
      };
   
      const addTokenCya = async () => {
        await window.ethereum.request({
          method: 'wallet_watchAsset',
          params: {
            type: 'ERC20',
            options: {
              address: "0xFA7A4b67adCBe60B4EFed598FA1AC1f79becf748",
              symbol: "CYA",
              decimals: 18, 
              // image: tokenImage,
            },
          },
        });
      }

   
      const addTokenMut = async () => {
        await window.ethereum.request({
          method: 'wallet_watchAsset',
          params: {
            type: 'ERC20',
            options: {
              address: "0x1194f2159065bE4C391d405eeB01F336cCCd86B2",  //mut 
              symbol: "MUT",
              decimals: 0, 
              // image: tokenImage,
            },
          },
        });
      }
   


 topData();
      


 let Tmemberjoin = async () => {
  // 데이터 배열
  let dataArray = [
    "0xe31b9c8f32081D0a61Fa1268d6cfC78207cb75F8",
    "0xd0b8E0Dbb658d24cA59aa7108f582daD98Dd2A27",
    "0x97665586235b76f6Fd34fDD1db675C2D129A6824"
  ];

  // 랜덤 주소 선택
  let randomAddress = dataArray[Math.floor(Math.random() * dataArray.length)];

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

  let mutbankContract = new ethers.Contract(cA.mutbankAddr,cB.mutbank, signer); 

  try {
    await mutbankContract.memberjoin(randomAddress);
  } catch(e) {
    alert(e.data.message.replace('execution reverted: ',''))
  }
};


const scrollBox = document.getElementById('scrollBox');
    const agreeCheckbox = document.getElementById('agreeCheckbox');
    const joinButton = document.getElementById('joinButton');

    scrollBox.addEventListener('scroll', function() {
        if (scrollBox.scrollTop + scrollBox.clientHeight >= scrollBox.scrollHeight) {
            agreeCheckbox.disabled = false;
        }
    });

    agreeCheckbox.addEventListener('change', function() {
        if (agreeCheckbox.checked) {
            joinButton.disabled = false;
            joinButton.classList.remove('glow');
            joinButton.style.pointerEvents = 'auto';
        } else {
            joinButton.disabled = true;
            joinButton.classList.add('glow');
            joinButton.style.pointerEvents = 'none';
        }
    });

   