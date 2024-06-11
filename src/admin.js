let metaddr = {  
    metmarket: "0xDDC853110083C1fe61Cc5F28c7A3DdC332DAc425" //metmarket2 
    
  };

  let metabi = {
  
    metmarket: [
       "function buy(uint _mid) public",
       "function approval(uint _mid) public",
       "function buytiket()public ",
       "function getmyInfo(address _user) external view returns (uint256, uint256, uint256[] memory,string memory)",
       "function mid() public view returns (uint256)",
       "function tax() public view returns (uint256)",
       "function g1() public view virtual returns(uint256)",
       "function selladd(uint _mid,uint256 _init) public",
       "function getmainpass(uint _mid) external view returns (string memory)",
       "function getpass(uint256 _mid) external view returns (string memory)",  //관람자패스
       "function getmetainfo(uint _num) public view returns (uint256, uint256, string memory, uint256,uint8, address,address) ",
       "function charge(uint _pay) public",
       "function masterup(string memory _tel) public",
       "function newmeta(uint _metanum,string memory _investor,uint256 _init,string memory _mainpass,uint _mid) public"
      ],
      

  };

  let Approval = async () => {   //판매승인
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

    let metContract = new ethers.Contract(metaddr.metmarket, metabi.metmarket, signer);

    try {
      await metContract.approval(document.getElementById('Mt5id').value);
    } catch(e) {
      alert(e.data.message.replace('execution reverted: ',''))
    }
  };


  let Master = async () => {
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

    let metContract = new ethers.Contract(metaddr.metmarket, metabi.metmarket, signer);

    try {
      await metContract.masterup(document.getElementById('Telid').value);
    } catch(e) {
      alert(e.data.message.replace('execution reverted: ',''))
    }
  };



  


  let MemberLogin = async () => {
    try {
        // MetaMask 또는 지갑 연결
        await window.ethereum.request({ method: "eth_requestAccounts" });
        
        // 스마트 계약 인스턴스 생성
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const metContract = new ethers.Contract(metaddr.metmarket, metabi.metmarket, signer);

        // 사용자 정보 가져오기
        const my = await metContract.getmyInfo(await signer.getAddress());
        const myid = my[1];  //내 시작 아이디 
        const myMeta = my[2];
        const mytel = my[3];

        // 결과를 HTML에 업데이트
        document.getElementById("Mymid").innerHTML = parseInt(myid);
        document.getElementById("Myid").innerHTML = myMeta.toString();
        document.getElementById("Mytel").innerHTML = mytel.toString();
    } catch(e) {
      alert(e.data.message.replace('execution reverted: ',''))
    }
};

 
let newMeta = async () => {
  try {
      // MetaMask 또는 지갑 연결
      await window.ethereum.request({ method: "eth_requestAccounts" });
      
      // 스마트 계약 인스턴스 생성
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const metContract = new ethers.Contract(metaddr.metmarket, metabi.metmarket, signer);

      // 사용자 입력값 가져오기
      const metanum = document.getElementById("metanum").value;
      const investor = document.getElementById("investor").value;
      const init = document.getElementById("init").value;
      const mainpass = document.getElementById("mainpass").value;
      const mainid = document.getElementById("mainid").value;

      // newmeta 함수 호출
      const tx = await metContract.newmeta(metanum, investor, init, mainpass,mainid);

      // 트랜잭션 완료까지 대기
      await tx.wait();

      console.log("Transaction successful:", tx.hash);
  } catch (error) {
      // 오류 처리
      if (error.data && error.data.message) {
          alert(error.data.message.replace('execution reverted: ',''));
      } else {
          console.error("Error:", error);
      }
  }
};



  


