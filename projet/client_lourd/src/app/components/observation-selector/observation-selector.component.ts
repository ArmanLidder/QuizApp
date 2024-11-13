import {Component} from '@angular/core';
import {MatDialog} from "@angular/material/dialog";
import {ObservationService} from "@app/services/observation.service/observation.service";
import {ObservationSelectorDialogComponent} from "@app/components/observation-selector-dialog/observation-selector-dialog.component";

@Component({
    selector: 'app-observation-selector',
    templateUrl: './observation-selector.component.html',
    styleUrls: ['./observation-selector.component.scss']
})
export class ObservationSelectorComponent {
    isMenuOpen: boolean = false;

    constructor(
        private dialog: MatDialog,
        public observationService: ObservationService,
    ) {}

    toggleMenu() {
        this.isMenuOpen = !this.isMenuOpen;
    }

    openSelectorDialog() {
        this.toggleMenu();
        const dialogRef = this.dialog.open(ObservationSelectorDialogComponent, {
            data: {playerObserved: this.observationService.observedPlayerId}
        }).afterClosed();
        dialogRef.subscribe(result => {
            if (result) {
                this.observationService.observedPlayerId = result;
            }
        });
    }
}
