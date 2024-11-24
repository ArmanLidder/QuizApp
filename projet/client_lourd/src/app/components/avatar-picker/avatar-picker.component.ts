import { Component, EventEmitter, Input, Output } from '@angular/core';
import { AvatarService } from "@app/services/avatar.service/avatar.service";

@Component({
    selector: 'app-avatar-picker',
    templateUrl: './avatar-picker.component.html',
    styleUrls: ['./avatar-picker.component.scss']
})
export class AvatarPickerComponent {
    @Output() avatarSelected = new EventEmitter<string | File>(); // Emit string (URL) or File (for custom uploads)
    @Input() showOwnedAvatars = false;

    defaultAvatars: string[] = [];
    ownedAvatars: string[] = [];
    loading: boolean = true; // Loading flag for spinner

    selectedAvatar: string | null = null;
    customAvatarFile: File | null = null;
    customAvatarUrl: string | ArrayBuffer | null = null;
    customAvatarSelected: boolean = false;

    constructor(private avatarService: AvatarService) {}

    async ngOnInit() {
        await this.loadAvatars();
    }

    async loadAvatars() {
        this.loading = true;
        this.avatarService.getDefaultAvatarUrls().subscribe((avatars: string[]) => {
            this.defaultAvatars = avatars;
        });
        if (this.showOwnedAvatars) this.ownedAvatars = await this.avatarService.getBoughtAvatars();
        this.loading = false;
    }

    selectAvatar(avatarUrl: string): void {
        this.customAvatarSelected = false;
        this.selectedAvatar = avatarUrl;
        this.avatarSelected.emit(this.selectedAvatar); // Emit the selected avatar URL
    }

    onCustomAvatarUploaded(event: Event): void {
        const input = event.target as HTMLInputElement;
        const file = input.files?.[0];
        if (file) {
            const validTypes = ['image/jpeg', 'image/png', 'image/jpg','image/webp'];
            if (!validTypes.includes(file.type)) {
                return;
            }
            this.customAvatarFile = file;
            const reader = new FileReader();
            reader.onload = () => {
                this.customAvatarUrl = reader.result;
                this.selectedAvatar = null;
                this.avatarSelected.emit(this.customAvatarFile as File);
                this.customAvatarSelected = true;
            };
            reader.readAsDataURL(file);
        }
    }

    selectCustomAvatar(): void {
        this.customAvatarSelected = true;
        this.selectedAvatar = null;
        this.avatarSelected.emit(this.customAvatarFile as File);
    }
}
