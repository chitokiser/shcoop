// SPDX-License-Identifier: MIT  
//ver1.2
pragma solidity >=0.7.0 <0.9.0;

  
  interface Icya{
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 
  }
  


    interface Imutbank{      //멋뱅크
     function depoup(address _user, uint _depo) external;
    function depodown(address _user, uint _depo) external;
    function getprice() external view returns (uint256);
    function getlevel(address user) external view returns (uint);
    function g9(address user) external view returns (uint);  // 각 depo현황
    function getagent(address user) external view returns (address);
    function getmento(address user) external view returns (address);
    function expup(address _user,uint _exp) external;
  
  }  
    
 
contract Mt5market2  {   //발행인 오너 별도  발행자격
  
  Icya cya;
  Imutbank mutbank;
  address public admin; 
  address public taxbank;
  uint256 public mid; 
  uint256 public masterfee;  //마스터등록비용
  uint256 public tax;  //매출
  
  

  mapping(address => uint8)public staff;
  mapping(uint256 => meta)public metainfo;  //id별 계좌정보
  mapping(address => my)public myinfo;  //발급자
  mapping(uint256 => string)private mainpass;  //nftid별 매칭되어 있는 계좌의 실제 비번
      
      
   constructor(address _cya, address _taxbank, address _mutbank) {
    cya = Icya(_cya);
    mutbank = Imutbank(_mutbank);
    admin = msg.sender;
    staff[msg.sender] = 5;
    taxbank = _taxbank;
    masterfee = 5000*1e18;
}


    struct meta{
    uint256 mid;
    uint256 metanum;
    string  investor;
    uint256 init;  //최초가격
    uint8 trade; //거래가능성
    address owner;  //계좌 오너
    address origin;  //발행인
    }

   
     struct my{  //발행자 자격
    uint256 depo;  //최초보증금
    uint256 myid; //내가 발행할 수 있는 첫id 기준
    uint256[]mymeta;//내가 발행한 계좌
    string tel; //발행인 텔레그램 id
    }


function staffup(address _staff,uint8 _level )public {   
    require(staff[msg.sender] >= 5,"no staff");
    staff[_staff] = _level;
} 

function taxbankup(address _taxbank )public {   
    require(staff[msg.sender] >= 5,"no staff");
    taxbank = _taxbank;
} 


function masterfeeup(uint256 _masterfee)public {   
    require(staff[msg.sender] >= 5,"no staff");
    masterfee = _masterfee*1e18;
} 


    function charge(uint _pay) public {  
        uint pay = _pay*1e18;
        require(g2(msg.sender) >= pay,"no cya");  
        cya.approve(msg.sender, pay); 
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
        mutbank.depoup(msg.sender,pay);
    }


    function masterup(string memory _tel) public {  //발행인 업
        require(mutbank.getmento(msg.sender) != address(0),"no member"); 
        require(myinfo[msg.sender].depo == 0,"already a publisher"); 
        require(g2(msg.sender) >= masterfee,"no cya"); 
        cya.approve(msg.sender,masterfee); 
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= masterfee, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this),masterfee);  
        tax += masterfee;
        myinfo[msg.sender].depo = masterfee;
        mutbank.depoup(mutbank.getmento(msg.sender),masterfee*10/100);
        myinfo[msg.sender].myid = mid;
        myinfo[msg.sender].tel = _tel;
        mid +=30;
        
    }
    

    
  
    
function newmeta(uint _metanum,string memory _investor,uint256 _init,string memory _mainpass,uint _mid) public{  
    uint mymid = myinfo[msg.sender].myid;
    require(myinfo[msg.sender].depo >= 1,"no master");
    require(metainfo[_mid].trade == 0 || metainfo[_mid].trade == 4,"Account that cannot be changed");
    require(mymid <= _mid && _mid < mymid + 30, "Out of setting range id");
    metainfo[_mid].mid = _mid;  //계좌id 설정
    metainfo[_mid].metanum = _metanum;  //계좌를 미리 매칭해둠
    metainfo[_mid].investor = _investor;  //관람자 비번
    metainfo[_mid].init = _init;  //시작가
    metainfo[_mid].trade = 3;  // 3이면 거래가능  2승인준비중 1플레이중 4밣행자 리셋가능
    mainpass[_mid] = _mainpass;  //배열 따로  
    metainfo[_mid].owner = taxbank; //최초 계좌원가 받을 계좌주인 
    metainfo[_mid].origin = msg.sender;  //발행자는 15%만 받는거임
    myinfo[msg.sender].mymeta.push(_mid);
}


   function buy(uint _mid) public {  
        uint pay = metainfo[_mid].init * 1e18;
        require(metainfo[_mid].trade == 3,"not for sale");
        require(mutbank.getlevel(msg.sender) >= 1,"no member");
        require(mutbank.g9(msg.sender) >= pay,"no point");  
        mutbank.depodown(msg.sender,pay);
        mutbank.expup(msg.sender,pay/1e16);
        metainfo[_mid].trade = 1;
        mutbank.depoup(metainfo[_mid].owner,pay);
        mutbank.depoup(metainfo[_mid].origin,pay*15/100);
        mutbank.depoup(mutbank.getmento(msg.sender),pay*5/100);
        metainfo[_mid].owner = msg.sender;
        tax += pay;
    }




function selladd(uint _mid, uint256 _init) public {  
    require(metainfo[_mid].owner == msg.sender, "no owner");
    require(metainfo[_mid].init * 120 / 100 <= _init, "little profit realization");
    metainfo[_mid].init = _init;  // 시작가 업데이트
    metainfo[_mid].trade = 2;  // 거래 대기상태
    
}


function approval(uint _mid) public {  //거래 가능 승인
     require(staff[msg.sender] >= 3,"no staff");
    require(metainfo[_mid].trade == 2, "lack of conditions");
    metainfo[_mid].trade = 3;  // 거래 가능상태
    taxtrans(); //cya이체
}


function tradereset(uint _mid) public {  //계좌 리셋
     require(staff[msg.sender] >= 3,"no staff");
    metainfo[_mid].trade = 4;  // 발행인에게 계좌 리셋하라는 신호
}


function telreset(string memory _tel) public {  //텔레그램 id 변경
     require( myinfo[msg.sender].depo >= 1,"no master");
     myinfo[msg.sender].tel = _tel;
}


function repaire(uint _mid,uint _metanum,string memory _pass,uint256 _init,string memory _mainpass) public{  
    
    require(staff[msg.sender] >= 5,"no staff");
    
    metainfo[_mid].metanum = _metanum;  //신규계좌 등록
    metainfo[_mid].investor=_pass;  //관람자 비번
    metainfo[_mid].init = _init;  //시작가
    metainfo[_mid].trade = 3;
    mainpass[_mid] = _mainpass;  //배열 따로  
}





function taxtrans( )internal{   
    uint pay = g1();
    cya.transfer(taxbank,pay);

    
} 

  
 function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

  function g2(address user) public view virtual returns(uint256){  
  return cya.balanceOf(user);
  }
  

  
  function getmainpass(uint _mid) external view returns (string memory){  //메인패스
     require(metainfo[_mid].owner == msg.sender,"no owner");
      return mainpass[_mid]; 
  }
  
  function getpass(uint256 _mid) external view returns (string memory){  //관람자 패스
      return metainfo[_mid].investor;  
  }
 
 

   function getmento(address user) external view returns (address){  //유저별멘토
      return mutbank.getmento(user) ;
  }

    function getlevel(address user) external view returns (uint){  //유저별 레벨
      return mutbank.getlevel(user);
  }
 

function getmetainfo(uint _num) public view returns (uint256, uint256, string memory, uint256,uint8, address,address) {
    require(_num < mid, "Invalid _num");
    meta memory m = metainfo[_num];
    return (m.mid, m.metanum, m.investor, m.init, m.trade, m.owner,m.origin);
}
function getmyInfo(address _user) external view returns (uint256, uint256, uint256[] memory,string memory) {
    return (
    
        myinfo[_user].depo,
        myinfo[_user].myid,
        myinfo[_user].mymeta,
        myinfo[_user].tel
    );
}

function getmymeta(address _user) external view returns (uint256[] memory) {
    return (
        myinfo[_user].mymeta
    );
}
}




  
    