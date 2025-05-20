import { Pessoa } from './Pessoa';

export class Dependente extends Pessoa {
    private parentesco: string;

    constructor(
        id: number = 0,
        nome: string = '',
        cpf: string = '',
        telefone: string = '',
        email: string = '',
        endereco: string = '',
        parentesco: string = ''
    ) {
        super(id, nome, cpf, telefone, email, endereco);
        this.parentesco = parentesco;
    }

    public getParentesco(): string {
        return this.parentesco;
    }

    public setParentesco(parentesco: string): void {
        this.parentesco = parentesco;
    }
} 