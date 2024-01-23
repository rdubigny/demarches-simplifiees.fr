import { ApplicationController } from './application_controller';
import { hide, show } from '@utils';

export class ClosingNotificationController extends ApplicationController {
  static targets = [
    'brouillonToggle',
    'emailContentBrouillon',
    'enCoursToggle',
    'emailContentEnCours'
  ];

  declare brouillonToggleTarget: HTMLInputElement;
  declare enCoursToggleTarget: HTMLInputElement;
  declare emailContentBrouillonTarget: HTMLElement;
  declare emailContentEnCoursTarget: HTMLElement;

  connect() {
    this.displayBrouillonInput();
    this.displayEnCoursInput();
    this.on('change', () => this.onChange());
  }

  onChange() {
    this.displayBrouillonInput();
    this.displayEnCoursInput();
  }

  displayBrouillonInput() {
    const brouillonToggleElement = this.brouillonToggleTarget as HTMLInputElement
    if (brouillonToggleElement.checked) {
      show(this.emailContentBrouillonTarget);
    } else {
      hide(this.emailContentBrouillonTarget);
    }
  }

  displayEnCoursInput() {
    const enCoursToggleElement = this.enCoursToggleTarget as HTMLInputElement
    if (enCoursToggleElement.checked) {
      show(this.emailContentEnCoursTarget);
    } else {
      hide(this.emailContentEnCoursTarget);
    }
  }
}
