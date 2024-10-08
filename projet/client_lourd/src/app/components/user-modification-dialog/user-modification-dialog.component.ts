import { Component, OnInit, Output, EventEmitter } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { ProfileService } from '@app/services/profile.service/profile.service';
import { AvatarService } from '@app/services/avatar.service/avatar.service';
//import { UserModificationData } from '@common/interfaces/user-data.interface';
import { environment } from "../../../environments/environment";
import { MatDialog } from "@angular/material/dialog";

interface AvatarData {
  name: string,
  url: string,
}

@Component({
  selector: 'app-user-modification-dialog',
  templateUrl: './user-modification-dialog.component.html',
  styleUrls: ['./user-modification-dialog.component.scss']
})
export class UserModificationDialogComponent implements OnInit {
  profileForm: FormGroup;
  defaultAvatars: AvatarData[] = [];
  selectedAvatarIndex: number | null = null;
  customAvatarUrl: string | ArrayBuffer | null = null;
  @Output() updateProfilData = new EventEmitter<void>()

  constructor(private dialog: MatDialog, private fb: FormBuilder, private profileService: ProfileService, private avatarService: AvatarService) {
    this.profileForm = this.fb.group({
      username: ['', [Validators.required, this.usernameValidator]],
      avatar: [null],
    });
  }

  ngOnInit() {
    // this.profileService.fetchUserProfile().subscribe((userProfil: UserModificationData) => {
    //   this.profileForm.patchValue({
    //     username: userProfil.username,
    //   });
    // });
    console.log(JSON.stringify(this.profileService.userData,null, 2))
    this.profileForm.patchValue({
      username: this.profileService.userData?.username ,
    });

    // Fetch default avatars
    this.avatarService.getDefaultAvatars().subscribe((res: any) => {
      this.defaultAvatars = res.defaultAvatars.map((avatar: string) => ({
        name: avatar,
        url: `${environment.serverUrl}/images/${avatar}`
      }));
    });
  }

  usernameValidator(control: AbstractControl): { [key: string]: boolean } | null {
    const usernameRegex = /^[a-zA-Z0-9]+$/;
    if (control.value && !usernameRegex.test(control.value)) {
      return {invalidUsername: true};
    }
    return null;
  }

  onFileSelected(event: Event) {
    const file = (event.target as HTMLInputElement).files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        this.customAvatarUrl = e.target?.result as string;
        this.selectedAvatarIndex = null;
        this.profileForm.patchValue({avatar: file});
      };
      reader.readAsDataURL(file);
    }
  }

  selectAvatar(index: number) {
    if (index === -1) {
      this.selectedAvatarIndex = null;
      return;
    }
    this.selectedAvatarIndex = index;
    this.profileForm.patchValue({avatar: this.defaultAvatars[index].name});
  }

  onSubmit() {
    if (this.profileForm.valid) {

      const formData = new FormData();

      formData.set('username', this.profileForm.controls['username'].value);
      if (this.customAvatarUrl && this.profileForm.controls['avatar'].value instanceof File) {
        formData.set('file', this.profileForm.controls['avatar'].value);
        const file = this.profileForm.controls['avatar'].value;
        const fileExt = file.name.split('.').pop();
        const fileName = this.profileForm.controls['username'].value + '.' + fileExt
        formData.set('avatar', fileName);
        this.profileForm.patchValue({avatar: fileName});
      } else {
        formData.set('avatar', this.profileForm.controls['avatar'].value)
      }
      this.profileService.updateUserProfile(formData);
      this.updateProfilData.emit();
      this.dialog.closeAll();
    }

  }
}
