package com.example.order.controller;

import com.example.order.dao.OrderDAO;
import com.example.order.dto.OrderItemTO;
import com.example.order.dto.OrderRequest;
import com.example.order.dto.OrderTO;
import com.example.order.dto.ProductTO;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Map;

@RestController
public class OrderController {

    private final OrderDAO orderDAO;

    @Autowired
    public OrderController(OrderDAO orderDAO) {
        this.orderDAO = orderDAO;
    }

    // 상품 목록 조회 - 영신
    @GetMapping("/products")
    public ArrayList<ProductTO> getAllProducts() {
        return orderDAO.productAll();
    }

    @PostMapping("/order")
    public ResponseEntity<String> createOrder(@RequestBody OrderRequest orderRequest) {
        orderDAO.createOrder(orderRequest);
        return ResponseEntity.ok("Order created successfully");
    }

    @GetMapping("/order/{email}")
    public ArrayList<OrderTO> getOrders(@PathVariable String email) {
        ArrayList<OrderTO> lists = orderDAO.orderList(email);

        return lists;
    }

    @PutMapping(value = "/order/{orderid}")
    public String putOrder(@PathVariable("orderid") String orderid,
                           @RequestBody Map<String, Object> request) {
        Map<String, Object> orderMap = (Map<String, Object>) request.get("order");
        Map<String, Object> orderItemMap = (Map<String, Object>) request.get("orderItem");

        OrderTO oto = new OrderTO();
        oto.setOrderId(Long.parseLong(orderid));
        oto.setEmail((String) orderMap.get("email"));
        oto.setDate(LocalDate.now());
        oto.setAddress((String) orderMap.get("address"));
        oto.setZipcode((String) orderMap.get("zipcode"));

        OrderItemTO oito = new OrderItemTO();
        oito.setOrderId(Long.parseLong(orderid));
        oito.setQuantity(Integer.parseInt((String)orderItemMap.get("quantity")));
        oito.setProductId(Long.parseLong((String)orderItemMap.get("productId")));

        int flag1 = orderDAO.order_update(oto);
        int flag2 =  orderDAO.orderitem_update(oito);
        System.out.println("flag1 : " + flag1 + ",flag2 : " + flag2);
        return "{\"flag1\" : " + flag1 + ", \"flag2\" : " + flag2 + "}";
    }

    @DeleteMapping("/order/{id}")
    public ResponseEntity<String> deleteOrder(@PathVariable long id) {
        boolean isDeleted = orderDAO.deleteOrder(id);
        if (isDeleted) {
            return new ResponseEntity<>("order delete success", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("order not found", HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/orders/{id}/show")
    public String showProduct(@PathVariable String id) {
        return "Showing details for order ID: " + id; // 실제 제품 상세정보로 대체 필요
    }
}
