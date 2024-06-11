// SPDX-License-Identifier: MIT  
// ver1.0
pragma solidity >=0.7.0 <0.9.0;

interface Icya {     
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface Isut {      
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function g1() external view returns(uint256);
  function getdepot(address user) external view returns(uint256);
}

contract Sutbank {
  Icya cya;
  Isut sut;
  uint256 public totaltax; // 누적 세금
  uint256 public tax;  // 세금
  uint8 public act;  //배당 가능여부    1=매수가능 2=배당 가능 3=매도가능
  uint256 public allow;
  address public bank; // 시아뱅크
  address public admin;
  uint256 public sum;   // 전체 참여 인원
  uint256 public sold;  // vet 유통 수량
  uint256 public fix;  // 토큰 가격 안정화를 위한 허수 초기값 1e6
  address public owner; // 조합 거버넌스
  uint256[] public chart; // 가격 챠트 구현을 위한 배열 저장
  uint256 public price;  // mut 가격
  mapping (address => my) public myinfo;
  mapping (address => uint) public staff;
  mapping (address => uint) public fa;
  mapping (address => uint) public allowt; // 배당 시간 
  event getdepo(uint amount);
     
  constructor(address _cya, address _sut, address _sutb) {
    fix = 1e16;  
    cya = Icya(_cya);
    sut = Isut(_sut);
    bank = _sutb;  // sut 뱅크
    price = 1e16;
    sold = 1000;
    act =3 ;
    admin = msg.sender;
    staff[msg.sender] = 10;
    myinfo[msg.sender].level = 10;
  }
    
  struct my {
    uint256 totaldepo; // 누적 배당 금액
    uint256 depo;
    uint256 level;
    address agent;
    address mento; 
    uint256 member;
    uint256 exp;
  }
    


  function actup(uint8 _num) public {  
    require(admin == msg.sender, "no admin"); 
    act = _num;
  }
  function staffup(address _staff, uint8 num) public {  
    require(admin == msg.sender, "no admin"); 
    staff[_staff] = num;
  }   

  function faup(address _fa) public {  
    require(admin == msg.sender, "no admin"); 
    fa[_fa] = 5;
  }   
  
  function depoup(address _user, uint _depo) public {  
    require(fa[msg.sender] >= 5, "no family");
    myinfo[_user].depo += _depo;
  }

  function expup(address _user, uint _exp) public {  
    require(fa[msg.sender] >= 5, "no family");
    myinfo[_user].exp += _exp;
  }

  function depodown(address _user, uint _depo) public {  
    require(fa[msg.sender] >= 5, "no family");
    myinfo[_user].depo -= _depo;
  }

  function agentadd(address _agent) public {   
    require(staff[msg.sender] >= 5, "no staff");
    myinfo[_agent].level = 10;
    myinfo[_agent].agent = msg.sender;
  } 

  function mentoadd(address _mento) public {    // 에이젼트가 멘토 등록
    require(myinfo[msg.sender].level >= 10, "no agent");
    require(myinfo[_mento].agent == address(0), "already mento");
    myinfo[_mento].level = 6;
    myinfo[_mento].agent = msg.sender;
    myinfo[_mento].mento = msg.sender;
  } 

  function memberjoin(address _mento) public {  
    require(myinfo[msg.sender].level == 0, "already member"); 
    require(myinfo[_mento].level >= 6, "no mento"); 
    myinfo[msg.sender].level = 1;
    myinfo[msg.sender].mento = _mento;
    myinfo[msg.sender].agent = myinfo[_mento].agent;
    myinfo[_mento].member += 1;
    sum += 1;
    taxout();
  }

  function ownerup(address _owner) public {  
    require(staff[msg.sender] >= 5, "no staff");
    owner = _owner;
  }

  function bankup(address _bank) public {  
    require(staff[msg.sender] >= 5, "no staff");
    bank = _bank;   // 초기값은 sutbank에 줄 것
  }

  function buysut(uint _num) public returns(bool) {  
    uint pay = _num * price;
    require(act >= 1, "Not for sale");  
    require(g3() >= _num, "sut sold out");  
    require(1 <= _num, "1 or more");
    require(1 <= myinfo[msg.sender].level, "no member");
    require(cya.balanceOf(msg.sender) >= pay, "no cya"); 
    cya.approve(msg.sender, pay); 
    uint256 allowance = cya.allowance(msg.sender, address(this));
    require(allowance >= pay, "Check the token allowance");
    cya.transferFrom(msg.sender, address(this), pay);  
    sut.transfer(msg.sender, _num);
    myinfo[msg.sender].exp += _num / 10;
    myinfo[myinfo[msg.sender].mento].depo += pay * 10 / 100;
    allowt[msg.sender] = block.timestamp;
    priceup();
    tax += pay * 5 / 100;
    return true;     
}

function levelup() public {
    uint256 mylev = myinfo[msg.sender].level;
    uint256 myexp = myinfo[msg.sender].exp;
    require(mylev >= 1  && myexp >= 2**mylev * 10000, "Insufficient requirements");
    myinfo[msg.sender].exp -= 2**mylev * 10000;
    myinfo[msg.sender].level += 1;
    taxout();
}

function sellsut(uint num) public returns(bool) {      
    uint256 pay = num * price;  
    require(act >= 3, "Can't sell"); 
    require(1 <= num, "1 or more");
    require(5 <= getlevel(msg.sender), "Level 5 or higher"); 
    require(g8(msg.sender) >= num, "no vet");
    require(g1() >= pay, "no cya");
    sut.approve(msg.sender, num);
    uint256 allowance = sut.allowance(msg.sender, address(this));
    require(allowance >= num, "Check the allowance");
    sut.transferFrom(msg.sender, address(this), num); 
    cya.transfer(msg.sender, pay);
    myinfo[msg.sender].level -= 1; // 레벨 1 줄어듬
    priceup();
    return true;
}

function allowcation() public returns(bool) {   // depo 증가
    require(act >= 2, "No dividend");  
    require(getlevel(msg.sender) >= 1, "no member");  
    require(g8(msg.sender) >= 5000, "More than 5000SUT"); 
    require(allowt[msg.sender] + 7 days < block.timestamp, "not time"); // 주 1회
    require(sut.getdepot(msg.sender) + 7 days < block.timestamp, "cut not time"); // 주 1회
    allowt[msg.sender] = block.timestamp;
    uint256 pay = getpay(msg.sender); 
    myinfo[msg.sender].depo += pay;
    myinfo[msg.sender].exp += 5000;
    emit getdepo(pay);
    return true;
}
  
function withdraw() public {    
    uint pay = myinfo[msg.sender].depo;
    require(pay >= 1, "no deposit"); 
    myinfo[msg.sender].depo = 0;
    require(pay <= g1(), "no cya");  
    myinfo[msg.sender].totaldepo += pay;
    cya.transfer(msg.sender, pay );
}

function taxout() public {  
    cya.transfer(bank, tax);
    totaltax += tax;
    tax = 0;
}
  
function fixup(uint256 _fix) public {  // 토큰 가격 균형을 위한 허수
    require(admin == msg.sender, "no admin");
    fix = _fix;  
}  

function priceup() public {
    sold = g11();
    allow = g1() / (sold); 
    price = allow + fix;
    chart.push(price);   
}


function g1() public view virtual returns(uint256) {  
    return cya.balanceOf(address(this));
}

function g3() public view returns(uint) { // cut 잔고 확인
    return sut.balanceOf(address(this));
}  

  function g4() public view virtual returns(uint){  
  return chart.length;
  }
    function g5(uint _num) public view virtual returns(uint256){  
  return chart[_num];
  }
function g6() public view virtual returns(uint256){  
  return sut.balanceOf(address(this));
  }
function g8(address user) public view returns(uint) {  // 유저 cct 잔고 확인
    return sut.balanceOf(user);
}  

function g9(address user) public view returns(uint) {  // f
    return myinfo[user].depo;
}  

function getlevel(address user) public view returns(uint) {  // 유저 레벨 확인
    return myinfo[user].level;
}  

function getagent(address user) public view returns(address) {  // 유저 에이젼트
    return myinfo[user].agent;
}  
    
function getmento(address user) public view returns(address) {  // 유저 멘토
    return myinfo[user].mento;
}  

function g10() public view virtual returns(uint256) {  
    return sut.g1();  
}

function g11() public view virtual returns(uint256) {  
    return g10() - g3();  // vet 총발행량 - 계약이 가지고 있는 met
}
  

function getpay(address user) public view returns (uint256) { // next dividend
    return g8(user) * allow * getlevel(user) / 2000;
}
  
function gettime() public view returns (uint256) {  
    return (allowt[msg.sender] + 604800) - block.timestamp;
}

function getprice() public view returns (uint256) {  
    return price;
}

function deposit() external payable {}
}
