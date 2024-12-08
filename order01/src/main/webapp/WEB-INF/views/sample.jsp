<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <script type="text/javascript">

    var selectedProducts = new Map();
    var orderRequest = new Map();
    var items = [];

    document.addEventListener('DOMContentLoaded', () => {
      const adminBtn = document.getElementById('user-btn');

      adminBtn.addEventListener('click', () => {
        window.location.href = "/view2";
      });
    });

    /*// 추가버튼 클릭시 작동 이벤트
    document.addEventListener('DOMContentLoaded', () => {
      const selectedProducts = new Map();

      document.getElementById('products-list').addEventListener('click', (e) => {
        if (e.target.classList.contains('add-btn')) {
          e.preventDefault();

          const productName = e.target.getAttribute('data-name');
            const selectedContainer = document.getElementById('selectedProducts');
            debugger;
            //const priceElement = selectedContainer.querySelector('.price'); // 가격 정보

            if (selectedProducts.has(productName)) {
              debugger;
              const currentQuantity = selectedProducts.get(productName);
              selectedProducts.set(productName, currentQuantity + 1);

              const productRow = document.querySelector(`[data-product="${productName}"]`);
              productRow.querySelector('span').textContent = `${currentQuantity}개`;
            } else {
              selectedProducts.set(productName, 1);

              const newRow = document.createElement('div');
              newRow.className = 'row';
              newRow.setAttribute('data-product', productName);
              debugger;
              newRow.innerHTML = `
          <h6 class="p-0">${productName}<span class="badge bg-dark text-light">1개</span></h6>
        `;

            selectedContainer.appendChild(newRow);
          }
        }
      });
    });*/






    // 상품 목록 가져오기 API 호출
    document.addEventListener("DOMContentLoaded", function () {
      const xhr = new XMLHttpRequest();
      xhr.open("GET", "/products", true);
      xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
          const products = JSON.parse(xhr.responseText);
          const productTableBody = document.getElementById("products-list");

          productTableBody.innerHTML = ""; // 데이터 초기화
          productTableBody.innerHTML +='<h5 className="flex-grow-0"><b>상품 목록</b></h5>'
          productTableBody.innerHTML +='<ul className="list-group products">'

          products.forEach(product => {
            const row = `
                         <li class="list-group-item d-flex mt-3" style="width: -webkit-fill-available;">
                          <div class="col" id="productId">\${product.productId}</div>
                          <div class="col-2"><img class="img-fluid" src="https://i.imgur.com/HKOFQYa.jpeg" alt=""></div>
                          <div class="col">
                            <div class="row text-muted">커피콩</div>
                            <div class="row" id="productName">\${product.name}</div>
                          </div>
                          <div class="col text-center price" id="price">\${product.price}</div>
                          <div class="col text-end action"><a class="btn btn-small btn-outline-dark add-btn" data-name="${product.name}" onclick="addOrderProduct(event)">추가</a></div>
                        </li>
                            `;

            productTableBody.innerHTML += row;
          });
          productTableBody.innerHTML += '</ul>';

        }
      };
      xhr.send();
    });

    function addOrderProduct(event) {
        // 클릭된 버튼 요소 가져오기
        const button = event.target;

        // 버튼의 상위 요소(<li>) 찾기
        const listItem = button.closest('li');

        // productId와 price 요소 찾기
        const productIdElement = listItem.querySelector('#productName');
        const priceElement = listItem.querySelector('#price');

        // 값 가져오기
        const productName = productIdElement ? productIdElement.textContent.trim() : null;
        const price = priceElement ? priceElement.textContent.trim() : null;
        const selectedContainer = document.getElementById('selectedProducts')

        if (selectedProducts.has(productName)) {
          const productInfo = selectedProducts.get(productName)
          productInfo.quantity += 1;
          productInfo.price =  productInfo.price * productInfo.quantity ;
          selectedProducts.set(productName, productInfo );

          const productRow = document.querySelector(`[data-product="\${productName}"]`);
          productRow.querySelector('span').textContent = `\${productInfo.quantity}개`;
        } else {
          //selectedProducts.set(productName, 1);
          selectedProducts.set(productName, { price: price, quantity: 1 });

          const newRow = document.createElement('div');
          newRow.className = 'row';
          newRow.setAttribute('data-product', productName);
          newRow.innerHTML = `
          <h6 class="p-0">\${productName}<span class="badge bg-dark text-light">1개</span></h6>
        `;


        selectedContainer.appendChild(newRow);
      }

      // 상품 추가시 주문가격 갱신
      let total =0;
      // 상품별 price 값 total에 더해준다
      selectedProducts.forEach(item => {
        const price = parseFloat(item.price);
        if (!isNaN(price)) {
          total += price;
        }
      });
      document.getElementById("totalPrice").textContent = total+"원";

    }


    // 주문하기
    function pay() {
      //유효성 체크
      if (!validateForm()) {
        return ;
      }


      let total =0;
      // 상품별 price 값 total에 더해준다
      selectedProducts.forEach(item => {
        const price = parseFloat(item.price);
        if (!isNaN(price)) {
          total += price;
        }
      });

      // 2. OrderTO 객체 만들기 (OrderRequest의 order)
      let orderTO = {
        email: document.getElementById('email').value,
        address: document.getElementById('address').value,
        zipcode: document.getElementById('zipcode').value,
        date: getCurrentDate(),  // getCurrentDate()는 위에서 정의한 함수
        totalPrice: total // 총 금액은 나중에 계산
      };

      selectedProducts.forEach((value, key) => {
        let orderItem = {
          productName: key,
          productId: document.getElementById('productId').textContent,
          quantity: value.quantity,
          price: value.price,
          email: document.getElementById('email').value,
          date: getCurrentDate(),
          address: document.getElementById('address').value,
          zipcode: document.getElementById('zipcode').value
        };

        items.push(orderItem);
      });

      // 최종 제출폼에 데이터 추가
      orderRequest.set("order", orderTO);
      orderRequest.set("items", items);


      const xhr = new XMLHttpRequest();
      xhr.open("POST", "/order", true);
      // 요청 헤더 설정
      xhr.setRequestHeader("Content-Type", "application/json");
      xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
          alert("결제가 완료 되었습니다.")
        }
      };
      // 요청 전송 (JSON 문자열로 변환)
      xhr.send(JSON.stringify(Object.fromEntries(orderRequest)));

    }

    function validateForm() {
      // 각 입력 요소 가져오기
      const email = document.getElementById('email').value;
      const address = document.getElementById('address').value;
      const zipcode = document.getElementById('zipcode').value;

      // 값 비어있는지 체크
      if (!email || !address || !zipcode) {
        alert('모든 필드를 입력해주세요!');
        return false;  // 폼 제출을 막음
      }

      // 이메일 형식 체크
      const emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
      if (!emailPattern.test(email)) {
        alert('유효한 이메일 주소를 입력해주세요!');
        return false;  // 이메일이 유효하지 않으면 제출 안됨
      }

      return true;
    }

    function getCurrentDate() {
      const today = new Date();

      // 날짜 정보 추출
      const year = today.getFullYear();
      const month = String(today.getMonth() + 1).padStart(2, '0');  // 월은 0부터 시작하므로 1을 더함
      const day = String(today.getDate()).padStart(2, '0');

      // YYYY-MM-DD 형식으로 반환
      //return `${year}-${month}-${day}`;
      return year +'-'+month+'-'+day;
    }

  </script>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-KyZXEAg3QhqLMpG8r+8fhAXLRk2vvoC2f3B09zVXn8CA5QIVfZOJ3BCsw2P0p/We" crossorigin="anonymous">
  <style>
    body {
      background: #ddd;
    }

    .card {
      margin: auto;
      max-width: 950px;
      width: 90%;
      box-shadow: 0 6px 20px 0 rgba(0, 0, 0, 0.19);
      border-radius: 1rem;
      border: transparent
    }

    .summary {
      background-color: #ddd;
      border-top-right-radius: 1rem;
      border-bottom-right-radius: 1rem;
      padding: 4vh;
      color: rgb(65, 65, 65)
    }

    @media (max-width: 767px) {
      .summary {
        border-top-right-radius: unset;
        border-bottom-left-radius: 1rem
      }
    }

    .row {
      margin: 0
    }

    .title b {
      font-size: 1.5rem
    }

    .col-2,
    .col {
      padding: 0 1vh
    }

    img {
      width: 3.5rem
    }

    hr {
      margin-top: 1.25rem
    }
    .products {
      width: 100%;
    }
    .products .price, .products .action {
      line-height: 38px;
    }
    .products .action {
      line-height: 38px;
    }

  </style>
  <title>Hello, world!</title>
</head>
<body class="container-fluid">

<div class="my-4 d-flex justify-content-center">
  <h1 class="m-4" id="main-title" class="mb-0">Grids & Circle</h1>
  <button class="m-4 btn btn-outline-secondary" id="user-btn">관리자용</button>
</div>

<div class="card">
  <div class="row">
    <div class="col-md-8 mt-4 d-flex flex-column align-items-start p-3 pt-0" id="products-list">

    </div>
    <div class="col-md-4 summary p-4">
      <div>
        <h5 class="m-0 p-0"><b>Summary</b></h5>
      </div>
      <br>
      <div id="selectedProducts">

      </div>
      <hr>


      <form>
        <div class="mb-3">
          <label for="email" class="form-label">이메일</label>
          <input type="email" class="form-control mb-1" id="email">
        </div>
        <div class="mb-3">
          <label for="address" class="form-label">주소</label>
          <input type="text" class="form-control mb-1" id="address">
        </div>
        <div class="mb-3">
          <label for="zipcode" class="form-label">우편번호</label>
          <input type="text" class="form-control" id="zipcode">
        </div>
        <div>당일 오후 2시 이후의 주문은 다음날 배송을 시작합니다.</div>
      </form>
      <div class="row pt-2 pb-2 border-top">
        <h5 class="col">총금액</h5>
        <h5 class="col text-end" id="totalPrice">원</h5>
      </div>
      <button class="btn btn-dark col-12" style="width:45%;" onclick="pay()">결제하기</button> <button class="btn btn-dark col-12" style="width:45%;">주문조회</button>


    </div>
  </div>
</div>
</body>
</html>