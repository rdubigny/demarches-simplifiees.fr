import { ApplicationController } from './application_controller';
import { hide, show } from '@utils';

export class ClosingReasonController extends ApplicationController {
  static targets = [
    'closingReason',
    'replacedByProcedureId',
    'replacedByExternalUrl'
  ];

  declare closingReasonTarget: HTMLSelectElement;
  declare replacedByProcedureIdTarget: HTMLInputElement;
  declare replacedByExternalUrlTarget: HTMLInputElement;

  connect() {
    this.displayInput();
    this.on('change', () => this.onChange());
  }

  onChange() {
    this.displayInput();
  }

  displayInput() {
    const closingReasonSelect = this.closingReasonTarget as HTMLSelectElement

    Array.from(closingReasonSelect.options).forEach((option) => {
      if (option.selected && option.value == 'internal_procedure') {
        show(this.replacedByProcedureIdTarget);
        hide(this.replacedByExternalUrlTarget);
        this.emptyValue(
          this.replacedByExternalUrlTarget.querySelector('input')
        );
      } else if (option.selected && option.value == 'external_procedure') {
        show(this.replacedByExternalUrlTarget);
        hide(this.replacedByProcedureIdTarget);
        this.emptyValue(
          this.replacedByProcedureIdTarget.querySelector('select')
        );
      } else if (option.selected && option.value == 'other') {
        hide(this.replacedByProcedureIdTarget);
        this.emptyValue(
          this.replacedByProcedureIdTarget.querySelector('select')
        );
        hide(this.replacedByExternalUrlTarget);
        this.emptyValue(
          this.replacedByExternalUrlTarget.querySelector('input')
        );
      }
    });
  }

  emptyValue(field) {
    if (field) {
      field.value = '';
    }
  }
}
