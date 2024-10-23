import {Component, EventEmitter, Output} from '@angular/core';
import {AvatarService} from "@app/services/avatar.service/avatar.service";

@Component({
    selector: 'app-avatar-picker',
    templateUrl: './avatar-picker.component.html',
    styleUrls: ['./avatar-picker.component.scss']
})
export class AvatarPickerComponent {
    @Output() avatarSelected = new EventEmitter<string | File>(); // Emit string (URL) or File (for custom uploads)
    defaultAvatars: string[] = [];
    selectedAvatar: string | null = null;
    customAvatarFile: File | null = null;
    customAvatarUrl: string | ArrayBuffer | null = null;
    customAvatarSelected: boolean = false;

    constructor(private avatarService: AvatarService) {
    }

    ngOnInit(): void {
        this.loadDefaultAvatars();
    }

    loadDefaultAvatars(): void {
        this.avatarService.getDefaultAvatarUrls().subscribe((avatars: string[]) => {
            this.defaultAvatars = avatars;
        });
    }

    // Called when a default avatar is selected
    selectAvatar(avatarUrl: string): void {
        this.customAvatarSelected = false;
        this.selectedAvatar = avatarUrl;
        this.avatarSelected.emit(this.selectedAvatar); // Emit the selected avatar URL
    }

    // Handle custom avatar upload (emit File directly)
    onCustomAvatarUploaded(event: Event): void {
        const input = event.target as HTMLInputElement;
        const file = input.files?.[0];
        if (file) {
            this.customAvatarFile = file; // Store the custom avatar file
            const reader = new FileReader();
            reader.onload = () => {
                this.customAvatarUrl = reader.result; // Set the custom avatar preview URL
                this.selectedAvatar = null; // Unselect default avatars when a custom one is uploaded
                this.avatarSelected.emit(this.customAvatarFile as File); // Emit the custom avatar file
                this.customAvatarSelected = true;
            };
            reader.readAsDataURL(file); // Read the file as a data URL for preview
        }
    }

    selectCustomAvatar(): void {
        this.customAvatarSelected = true;
        this.selectedAvatar = null
        this.avatarSelected.emit(this.customAvatarFile as File);
    }

}
