package com.hospital.finance.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class FinanceAIControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @Test
    public void testAnalyseEndpointExists() throws Exception {
        mockMvc.perform(get("/finance/analyse"))
                .andExpect(status().isOk()); // 200 attendu si l'endpoint existe
    }
}
