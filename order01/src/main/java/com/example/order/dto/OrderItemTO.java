package com.example.order.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.apache.ibatis.type.Alias;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Alias(value="orderItemTO")
public class OrderItemTO {
    private int quantity;
    private long productId;
    private long orderId;
    private String email;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;
    private String address;
    private String zipcode;
    private int price;
}
