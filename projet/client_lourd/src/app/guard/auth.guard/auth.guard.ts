// import { inject } from '@angular/core';
// import { Router } from '@angular/router';
// // import { AdminAuthenticatorService } from '@app/services/admin-authenticator.service/admin-authenticator.service';
// // import { tap } from 'rxjs';
// // import { GAME_ADMIN_PROMPT } from '@common/page-url/page-url';
// import {AuthService} from "@app/services/auth.service/auth.service";

export const authGuardAuthentification = () => {
    // const router = inject(Router);
    // const authServices = inject(AuthService);
    // const token = authServices.getToken();
    // if (!token) {
    //     router.navigate(['/login']);
    //     return false
    // }
    return true;
};
