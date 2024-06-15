// SPDX-License-Identifier: MIT  
// ver1.2
pragma solidity >=0.7.0 <0.9.0;

interface Icya {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 
}

interface Isutbank {
    function depoup(address _user, uint _depo) external;
    function depodown(address _user, uint _depo) external;
    function getprice() external view returns (uint256);
    function getlevel(address user) external view returns (uint);
    function g9(address user) external view returns (uint); // 각 depo현황
    function getagent(address user) external view returns (address);
    function getmento(address user) external view returns (address);
    function expup(address _user, uint _exp) external;
}

contract Sutrealmarket { //부동산마켓
    Icya cya;
    Isutbank sutbank;
    address public admin; 
    address public taxbank;
    uint256 public mid; 
    uint256 public tax; // 매출
    uint256 public userfee; // 오너수익 기본값 95
  
    mapping(address => uint8) public staff;
    mapping(uint256 => Meta) public metainfo; // id별 계좌정보
    mapping(address => My) public myinfo; // id별 계좌정보
   

      
    constructor(address _cya, address _taxbank, address _sutbank) {
        cya = Icya(_cya);
        sutbank = Isutbank(_sutbank);
        admin = msg.sender;
        staff[msg.sender] = 5;
        taxbank = _taxbank;
        userfee = 95;
    }

    struct Meta {
        string name; // 물건이름
        string location; // 물건 위치 주소
        string detail; // 물건 정보 상세페이지
        string img; // 물건 사진
        uint256 time; // 사용가능 시간 최소단위 1일
        uint256 start; // 시작시간
        uint256 price; // 30일 기준
        uint8 trade; // 거래가능성 (3: 거래가능, 2: 준비중, 1: 사용중)
        address user; // 사용자
    }

    struct My {  // 발행자
        uint256[] mymeta; // 내가 발행한 계좌
        string tel; // 발행인 텔레그램 id
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not admin");
        _;
    }

    modifier onlyStaff(uint level) {
        require(staff[msg.sender] >= level, "Insufficient staff level");
        _;
    }

    function staffup(address _staff, uint8 _level) public onlyStaff(5) {   
        staff[_staff] = _level;
    } 


     function nameup(uint256 _mid,string memory _name) public onlyStaff(5) {   
        metainfo[_mid].name = _name;
    } 

  
       function locationup(uint256 _mid,string memory _location) public onlyStaff(5) {   
        metainfo[_mid].location = _location;
    } 
    
        function detailup(uint256 _mid,string memory _detail) public onlyStaff(5) {   
        metainfo[_mid].detail = _detail;
    } 

        function imagesup(uint256 _mid,string memory _img) public onlyStaff(5) {   
        metainfo[_mid].img = _img;
    } 
     

          function timeup(uint256 _mid,uint256 _time) public onlyStaff(5) {   
        metainfo[_mid].time = _time * 30 days;
    } 
     
          function startup(uint256 _mid) public onlyStaff(5) {   
        metainfo[_mid].start = block.timestamp;
    } 

        function priceup(uint256 _mid,uint256 _price) public onlyStaff(5) {   
        metainfo[_mid].price = _price *1e18;
    } 


    function userfeeup(uint256 _newFee) public onlyStaff(5) {   
        userfee = _newFee;
    } 

   

    function taxbankup(address _taxbank) public onlyStaff(5) {   
        taxbank = _taxbank;
    } 

    
 

    

 
    function charge(uint _pay) public {  
        uint pay = _pay*1e18;
        require(g2(msg.sender) >= pay,"no cya");  
        cya.approve(msg.sender, pay); 
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
        sutbank.depoup(msg.sender,pay);
    }
    


    
    function newMeta(string memory _name, string memory _location, string memory _detail, string memory _img, uint256 _price) public onlyStaff(5) {
      
        Meta storage meta = metainfo[mid];
        meta.name = _name;
        meta.location = _location;
        meta.detail = _detail;
        meta.img = _img;
        meta.price = _price*1e18;  // 1일기준
        meta.user = msg.sender;
        meta.trade = 3; // 3이면 거래 가능
        myinfo[msg.sender].mymeta.push(mid);
        mid += 1 ;
    }

  

    function buyMeta(uint _mid, uint _time) public {  //1일 기준
        uint pay = (metainfo[_mid].price * _time);
        require(metainfo[_mid].trade == 3, "Not for sale");
        require(sutbank.getlevel(msg.sender) >= 1, "No membership level");
        require(sutbank.g9(msg.sender) >= pay, "Insufficient points");  
        sutbank.depodown(msg.sender, pay);
        sutbank.expup(msg.sender, pay / 1e16);
        metainfo[_mid].trade = 1; // 물건 사용 중
        sutbank.depoup(metainfo[_mid].user, pay * userfee / 100);
        metainfo[_mid].user = msg.sender;
        metainfo[_mid].start = block.timestamp;
        metainfo[_mid].time = _time *30 days; 
    }

    function listMetaForSale(uint _mid, uint256 _price) public {  // 유저가 재판매
        require(metainfo[_mid].user == msg.sender, "Not the user");
          require(metainfo[_mid].trade == 1, "Not in use");
        require(metainfo[_mid].start + metainfo[_mid].time > block.timestamp + 30 days, "Time left");
        metainfo[_mid].price = _price; // 가격 조정
        metainfo[_mid].trade = 3; // 거래 가능 상태
    }

    

    function stopUsingStaff(uint _mid) public onlyStaff(5) {
    
        metainfo[_mid].trade = 3;  // 거래가능 상태 변경
        metainfo[_mid].user = address(0);
    }


    function taxTransfer() public {   
        uint pay = g1();
        cya.transfer(taxbank, pay);
    } 

    function g1() public view virtual returns (uint256) {  
        return cya.balanceOf(address(this));
    }

    function g2(address user) public view virtual returns (uint256) {  
        return cya.balanceOf(user);
    }

    function g3(uint _mid) public view virtual returns (uint256) { // 사용료 1시간당 산출
        return metainfo[_mid].price;
    }

      function g4(uint _mid) public view virtual returns (uint256) { //서비스 남은시간 보기
        return(metainfo[_mid].time + metainfo[_mid].start)  - block.timestamp ;
    }

    function getMento(address user) external view returns (address) {
        return sutbank.getmento(user);
    }

    function getLevel(address user) external view returns (uint) {
        return sutbank.getlevel(user);
    }

    function getMyMeta(address _user) external view returns (uint256[] memory) {
        return myinfo[_user].mymeta;
    }
}
