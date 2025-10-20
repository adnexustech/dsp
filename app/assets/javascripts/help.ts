// Radio button form auto-submit handler
document.addEventListener('DOMContentLoaded', (): void => {
    const radioInputs: NodeListOf<HTMLInputElement> = document.querySelectorAll('input[type="radio"]');

    radioInputs.forEach((radioInput: HTMLInputElement): void => {
        radioInput.addEventListener('change', function(this: HTMLInputElement): void {
            const form: HTMLFormElement | null = this.closest('form');
            if (form) {
                form.submit();
            }
        });
    });
});
