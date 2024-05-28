// import { createRouter, createWebHistory } from 'vue-router'
// import HomeView from '../views/HomeView.vue'

// const router = createRouter({
//   history: createWebHistory(import.meta.env.BASE_URL),
//   routes: [
//     {
//       path: '/',
//       name: 'home',
//       component: HomeView
//     },
//     {
//       path: '/about',
//       name: 'about',
//       // route level code-splitting
//       // this generates a separate chunk (About.[hash].js) for this route
//       // which is lazy-loaded when the route is visited.
//       component: () => import('../views/AboutView.vue')
//     }
//   ]
// })

// export default router
import {createWebHistory, createRouter} from "vue-router";
import ClientManagement from "../views/ClientManagement.vue";
import SavingAccountManagement from "../views/SavingAccountManagement.vue";
import CheckingAccountManagement from "../views/CheckingAccountManagement.vue";
import LoanManagement from "../views/LoanManagement.vue";
import BusinessStatistics from "../views/BusinessStatistics.vue";

const routes = [
    {
        path: "/",
        redirect: "/client",
    },
    {
        path: "/client",
        name: "ClientManagement",
        component: ClientManagement
    },
    {
        path: "/saving_account",
        name: "SavingAccountManagement",
        component: SavingAccountManagement
    },
    {
        path: "/checking_account",
        name: "CheckingAccountManagement",
        component: CheckingAccountManagement
    },
    {
        path: "/loan",
        name: "LoanManagement",
        component: LoanManagement
    },
    {
        path: "/statistics",
        name: "BusinessStatistics",
        component: BusinessStatistics
    }
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

export default router;
